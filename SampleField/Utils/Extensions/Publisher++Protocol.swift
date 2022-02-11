//
//  Publisher++Protocol.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/10/22.
//

import Foundation
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    
    public func replaceAnyInconsistency(with output: Self.Output) -> Publishers.ReplaceError<Publishers.ReplaceEmpty<Self>> {
        self.replaceEmpty(with: output)
            .replaceError(with: output)
    }
    
    public func replaceAnyInconsistency<T>(with output: T) -> Publishers.Map<Publishers.ReplaceError<Publishers.ReplaceEmpty<Self>>,T> where Self.Output == T? {
        self.replaceEmpty(with: output)
            .replaceError(with: output)
            .replaceNil(with: output)
    }
    
    public func conditionalMap<T>(if statement: @escaping (Self.Output) -> Bool,
                                  satisfied transform1: @escaping @autoclosure () -> T,
                                  else transform2: @escaping @autoclosure () -> T) -> Publishers.Map<Self, T> {
        self.map { output in
            if statement(output) {
                return transform1()
            }
            return transform2()
        }
    }
    
    public func conditionalMap<T>(if statement: @escaping @autoclosure () -> Bool,
                                  satisfied transform1: @escaping @autoclosure () -> T,
                                  else transform2: @escaping @autoclosure () -> T) -> Publishers.Map<Self, T> {
        self.map { output in
            if statement() {
                return transform1()
            }
            return transform2()
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher where Self.Failure == Never {
    
    func assign(to failablePublished: CurrentValuePublished<Self.Output,Self.Failure>) -> AnyCancellable {
        self.assign(to: \.wrappedValue, on: failablePublished)

    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
class CurrentValuePublished<Value,Failure> where Failure: Error {

    var wrappedValue: Value {
        get {
            _subject.value
        }
        set {
            _subject.send(newValue)
        }
    }

    var subject: AnyPublisher<Value,Failure> {
        _subject.eraseToAnyPublisher()
    }
    
    var projectedValue: CurrentValuePublished<Value,Failure> {
        self
    }

    private var _subject: CurrentValueSubject<Value,Failure>

    init(wrappedValue: Value, ErrorType: Failure.Type) {
        self._subject = .init(wrappedValue)
    }
    
    init(wrappedValue: Value) where Failure == Never {
        self._subject = .init(wrappedValue)
    }

}
