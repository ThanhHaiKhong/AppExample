import Foundation
import SwiftProtobuf
import SystemPackage
import WasmKit

actor WasmTaskManager {
    static let shared = WasmTaskManager()
    var tasks: [UInt32: Task<Data, Error>] = [:]
    func release() {
        for (_, task) in tasks {
            task.cancel()
        }
        tasks.removeAll()
    }

    nonisolated func run(_ task: Task<Data, Error>, key: UInt32) {
        let sema = DispatchSemaphore(value: 0)
        Task {
            defer {
                sema.signal()
            }
            await self._run(task, key: key)
        }
        sema.wait()
    }

    private func _run(_ task: Task<Data, Error>, key: UInt32) {
        tasks[key] = Task {
            defer {
                self.tasks.removeValue(forKey: key)
            }
            return try await task.value
        }
    }
}


class _AsyncWasm {
    let instance: Instance
    init(path: String) throws {
        let module = try parseWasm(filePath: FilePath(path))
        let engine = Engine()
        let store = Store(engine: engine)
        var imports = Imports()
        
        imports.define(module: "asyncify", name: "log", Function(
            store: store,
            parameters: [.i32, .i32],
            results: [],
            body: { caller, args in
                assert(args.count == 2)
                let memory = caller.instance!.exports[memory: "memory"]!
                let msg = memory.string(fromByteOffset: args[0].i32, len: Int(args[1].i32)) ?? ""
                WALogger.guest.debug(msg)
                return []
            }
        ))
        imports.define(module: "asyncify", name: "usleep", Function(
            store: store,
            parameters: [.i32],
            body: { _, args in
                assert(args.count == 2)
                WALogger.guest.debug("sleeping \(args[0].i32) us")
                usleep(args[0].i32)
                return []
            }
        ))
        imports.define(module: "asyncify", name: "uuid_v4", Function(
            store: store,
            parameters: [.i32],
            body: { caller, args in
                assert(args.count == 1)
                let outPtr = args[0].i32
                let memory = caller.instance!.exports[memory: "memory"]!
                try memory.copy(from: UUID().uuidString.to_wa(in: caller.instance!), to: outPtr)
                return []
            }
        ))
        imports.define(module: "asyncify", name: "get", Function(
            store: store,
            parameters: [.i32, .i32],
            results: [],
            body: { caller, args in
                measure(msg: "get") {
                    // parameters: output, offset
                    assert(args.count == 2)

                    let outPtr = args[0].i32
                    let memory = caller.instance!.exports[memory: "memory"]!
                    let deallocator = caller.instance!.exports[function: "release"]!
                    let input = memory.load(fromByteOffset: args[1].i32, as: WAFuture.self)
                    let sema = DispatchSemaphore(value: 0)
                    Task.detached {
                        WALogger.host.debug("[\(outPtr.hex)] started")
                        defer {
                            sema.signal()
                        }
                        let argsPtr = try await input.args(with: caller.instance!,
                                                           outPtr: outPtr,
                                                           fnPtr: 0,
                                                           callback: false)
                        do {
                            try deallocator([.i32(argsPtr[0])])
                        } catch {}
                    }
                    sema.wait()
                    WALogger.host.debug("[\(outPtr.hex)] finished")
                    return []
                }
            }
        ))
        imports.define(module: "asyncify", name: "get_async", Function(
            store: store,
            parameters: [.i32, .i32, .i32],
            results: [],
            body: { caller, args in
                try measure(msg: "get_async") {
                    // parameters: output, fn, offset
                    assert(args.count == 3)

                    let outPtr = args[0].i32
                    let fnPtr = args[1].i32
                    let memory = caller.instance!.exports[memory: "memory"]!
                    let input = memory.load(fromByteOffset: args[2].i32, as: WAFuture.self)
                    // save context to output
                    try memory.copy(
                        from: WAFuture(
                            data: 0,
                            len: 0,
                            callback: fnPtr,
                            context: input.context,
                            context_len: input.context_len,
                            // store `index` with value is `output` pointer to run task after
                            index: outPtr
                        ), to: outPtr
                    )
                    WALogger.host.debug("[\(outPtr.hex)] enqueue task \(args.map { $0.i32.hex })")
                    WALogger.host.debug("[\(outPtr.hex)] input <\(args[2].i32.hex)> \(input.debugDescription)")
                    WasmTaskManager.shared.run(Task(priority: .background) {
                        // - store tasks with key `outPtr`
                        WALogger.host.debug("[\(outPtr.hex)] async started")
                        defer {
                            WALogger.host.debug("[\(outPtr.hex)] async finished")
                        }
                        let deallocator = caller.instance!.exports[function: "release"]!
                        let memory = caller.instance!.exports[memory: "memory"]!
                        let callback = caller.instance!.exports[function: "callback"]!
                        try Task.checkCancellation()
                        let argsPtr = try await input.args(with: caller.instance!,
                                                           outPtr: outPtr,
                                                           fnPtr: fnPtr,
                                                           callback: true)
                        try Task.checkCancellation()
                        // execute `fn`
                        try callback([.i32(outPtr), .i32(fnPtr), .i32(argsPtr[0])])
                        try Task.checkCancellation()
                        let result = memory.load(fromByteOffset: outPtr, as: WAFuture.self)
                        var val: Data
                        // wasm call another async `get` function
                        if result.callback != 0 && result.index != 0 {
                            WALogger.host.debug("[\(outPtr.hex)] call child \(result.index.hex)")
                            val = try await WasmTaskManager.shared.tasks[result.index]!.value
                        } else {
                            val = result.data(in: memory)
                            do {
                                try deallocator([.i32(outPtr)])
                            } catch {}
                            if result.data != 0 {
                                do {
                                    try deallocator([.i32(result.data)])
                                } catch {}
                            }
                        }
                        do {
                            try deallocator([.i32(argsPtr[0])])
                            try deallocator([.i32(argsPtr[1])])
                        } catch {}
                        WALogger.host.debug("[\(outPtr.hex)] dequeue task")
                        return val
                    }, key: outPtr)
                    return []
                }
            })
        )
        
        instance = try module.instantiate(store: store, imports: imports)
    }

    /// call with input to caller wasm
    /// caller:
    /// - args: ouput, input_ptr, input_len
    func call(_ data: Data) async throws -> Data {
        let caller = instance.exports[function: "call"]!
        let allocator = instance.exports[function: "allocate"]!
        let deallocator = instance.exports[function: "release"]!
        let memory = instance.exports[memory: "memory"]!
        let outPtr = try allocator([.i32(UInt32(MemoryLayout<WAFuture>.size))])[0].i32
        // copy input to heap
        let inputPtr = try memory.set(data: data, in: allocator)
        try caller([.i32(outPtr), .i32(inputPtr), .i32(UInt32(data.count))])
        // extract `outPtr`
        let result = memory.load(fromByteOffset: outPtr, as: WAFuture.self)
        try Task.checkCancellation()
        if result.index != 0, let task = await WasmTaskManager.shared.tasks[result.index] {
            return try await task.value
        }
        defer {
            // clean
            do {
                try deallocator([.i32(outPtr)])
                try deallocator([.i32(inputPtr)])
            } catch {}
            // - check error
        }
        return result.data(in: memory)
    }

    func release() async {
        await WasmTaskManager.shared.release()
    }

    deinit {
        WALogger.host.debug("wasm deinit")
    }
}
