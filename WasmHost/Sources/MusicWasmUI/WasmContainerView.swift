//
//  WasmContainerView.swift
//  app
//
//  Created by L7Studio on 10/2/25.
//
import AsyncWasm
import OSLog
import SwiftUI

@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
public struct WasmContainerView<ContentView: View>: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable var engine: WasmEngine
    @ViewBuilder var contentView: (EngineVersion) -> ContentView
    @Environment(\.wasmBuilder) var builder
    var updater: Updater { engine.updater }
    public enum Mode { case manual, automatic}
    let mode: Mode
    public init(engine: WasmEngine,
                mode: Mode = .automatic,
                contentView: @escaping (EngineVersion) -> ContentView) {
        self.engine = engine
        self.mode = mode
        self.contentView = contentView
    }
    public var body: some View {
        VStack {
            switch updater.state {
            case .initializing:
                ProgressView()
                    .task {
                        await checkUpdate()
                    }
            case let .initialized(version):
                VStack {
                    Button("Continue with \(version.next.name)") {
                        Task.detached {
                            try await updater.download(version: version.next)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Skip with \(version.name)") {
                                Task.detached {
                                    try await updater.download(version: version)
                                }
                            }
                        }
                    }
                    Button("Reset", role: .destructive) {
                        Task.detached {
                            try await engine.remove(for: version)
                            await MainActor.run {
                                self.updater.state = .initializing
                            }
                        }
                    }
                }
            case let .downloading(ver, val):
                ProgressView(value: val) {
                    Text("Downloading \(ver.name) ...")
                }
                .progressViewStyle(.linear)
                .padding()
            case let .done(version):
                contentView(version)
            case let .failed(error):
                VStack {
                    Text(error.localizedDescription)
                        .font(.body)
                        .padding()
                    Button("Retry") {
                        self.updater.state = .initializing
                        Task.detached {
                            await checkUpdate()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onChange(of: scenePhase) {  newPhase in
            if newPhase == .active {
                if case .initializing = updater.state { return }
                Task.detached {
                    await checkUpdate()
                }
            }
        }
        .toolbar {
            if case let .done(version) = updater.state {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        SettingsView(engine: engine, version: version)
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
    
    func checkUpdate() async {
        do {
            // load selected or embedded
            try await engine.load(with: builder, version: nil)
            let version = try await engine.checkUpdate()
            try await updater.initialize(version: version)
            if version.hasNext {
                if case .automatic = mode {
                    Task.detached {
                        try await updater.download(version: version.next)
                    }
                } else {
                    updater.state = .initialized(version)
                }
            } else {
                updater.state = .done(version)
            }
        } catch is CancellationError {
        } catch {
            updater.state = .failed(error)
        }
    }
}
@available(iOS 17, macOS 14, tvOS 17, watchOS 10, *)
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var engine: WasmEngine
    let version: EngineVersion
    var body: some View {
        List {
            Button("Reset", role: .destructive) {
                Task {
                    try await engine.remove(for: version)
                    await MainActor.run {
                        self.engine.updater.state = .initializing
                        dismiss()
                    }
                }
            }
        }
    }
}
