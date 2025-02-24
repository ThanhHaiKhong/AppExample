import UIKit

struct Combining<A>: Sendable {
    let combine: @Sendable (A, A) -> A
}

struct EmptyInitializing<A>: Sendable {
    let create: @Sendable () -> A
}

extension Array {
    func reduce(
        _ initial: EmptyInitializing<Element>,
        _ combining: Combining<Element>
    ) -> Element {
        return self.reduce(initial.create(), combining.combine)
    }
}



//
//extension Combining where A == Int {
//    static let sum = Combining(combine: +)
//    static let product = Combining(combine: *)
//}
//
//extension EmptyInitializing where A == Int {
//    static let zero = EmptyInitializing { 0 }
//    static let one = EmptyInitializing { 1 }
//}
