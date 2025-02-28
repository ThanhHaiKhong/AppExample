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
*/

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
