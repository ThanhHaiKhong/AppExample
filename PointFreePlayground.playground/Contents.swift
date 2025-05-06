

func makeGreeter() -> () -> String {
    let name = "Adam"
    let greeter: () -> String = {
        return "Hello, \(name)"
    }
    return greeter
}

var completionHandles: [() -> Void] = []

@MainActor
func addCompletionHandle(_ handle: @escaping () -> Void) {
    completionHandles.append(handle)
}

func makeCounter() -> () -> Int {
    var count: Int = 0
    let increment = { () -> Int in
        count += 1
        return count
    }
    return increment
}

let counter = makeCounter()
counter() // 1
counter() // 2
