import UIKit

/*
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

class Car: CustomStringConvertible {
    var make: String
    var model: String
    var year: Int
    
    init(make: String, model: String, year: Int) {
        self.make = make
        self.model = model
        self.year = year
    }
    
    var description: String {
        return "\(make) \(model) \(year)"
    }
}

class Person {
    var name: String
    var age: Int
    weak var car: Car?
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

class Lessor {
    var person: Person
    var car: Car
    
    init(person: Person, car: Car) {
        self.person = person
        self.car = car
    }
}

var toyota = Car(make: "Toyota", model: "Camry", year: 2022)
var jane = Person(name: "Jane", age: 30)
var tony = Person(name: "Tony", age: 40)
var lessor = Lessor(person: jane, car: toyota)
jane.car = toyota
tony.car = toyota

print("Jane's car: \(String(describing: jane.car?.description))")
print("Tony's car: \(String(describing: tony.car?.description))")

toyota = Car(make: "Toyota", model: "Corolla", year: 2024)

print("--------------------------------------------------------")

print("Jane's car: \(String(describing: jane.car?.description))")
print("Tony's car: \(String(describing: tony.car?.description))")
*/

struct Describing<A> {
    var describe: (A) -> String
}

struct Combining<A> {
    let combine: (A, A) -> A
}

struct EmptyInitializing<A> {
    let create: () -> A
}

extension Array {
    func reduce(
        _ initial: Element,
        _ combining: Combining<Element>
    ) -> Element {
        return self.reduce(initial, combining.combine)
    }
    
    func reduce(
        _ initial: EmptyInitializing<Element>,
        _ combining: Combining<Element>
    ) -> Element {
        return self.reduce(initial.create(), combining.combine)
    }
}

extension Combining where A: Numeric {
    @MainActor static var sum: Combining {
        return Combining(combine: +)
    }
    @MainActor static var product: Combining {
        return Combining(combine: *)
    }
}

extension EmptyInitializing where A: Numeric {
    @MainActor static var zero: EmptyInitializing {
        return EmptyInitializing { 0 }
    }
    @MainActor static var one: EmptyInitializing {
        return EmptyInitializing { 1 }
    }
}

[1, 2, 4, 5].reduce(.zero, .sum)
[1, 2, 4, 5].reduce(.one, .product)

struct Equating<A> {
    let equals: (A, A) -> Bool
}

extension Equating where A == Int {
    @MainActor static let int = Equating(equals: ==)
}

extension Equating where A == Void {
    @MainActor static let void = Equating(equals: { _, _ in true })
}

extension Equating {
    static func array(of equating: Equating<A>) -> Equating<[A]> {
        return Equating<[A]> { lhs, rhs in
            guard lhs.count == rhs.count else { return false }
            for (a, b) in zip(lhs, rhs) {
                if !equating.equals(a, b) {
                    return false
                }
            }
            return true
        }
    }
    
    static func tupple(of equating: Equating<A>) -> Equating<(A, A)> {
        return Equating<(A, A)> { lhs, rhs in
            return equating.equals(lhs.0, rhs.0) && equating.equals(lhs.1, rhs.1)
        }
    }
}

Equating.array(of: .int).equals([1, 2, 3], [1, 2, 3])
Equating.array(of: .int).equals([1, 2, 3], [1, 2, 4])
