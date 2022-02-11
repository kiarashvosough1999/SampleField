//
//  Publisher++Protocol.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/10/22.
//

import Foundation
import Combine

extension Publisher  {
    
    public func replaceAnyInconsistency(with output: Self.Output) -> Publishers.ReplaceError<Publishers.ReplaceEmpty<Self>> {
        self.replaceEmpty(with: output)
            .replaceError(with: output)
    }
    
    public func replaceAnyInconsistency<T>(with output: T) -> Publishers.Map<Publishers.ReplaceError<Publishers.ReplaceEmpty<Self>>,T> where Self.Output == T? {
        self.replaceEmpty(with: output)
            .replaceError(with: output)
            .replaceNil(with: output)
    }
}

extension Publisher where Self.Failure == Never {
    
    func assign(to failablePublished: CurrentValuePublished<Self.Output,Self.Failure>) -> AnyCancellable {
        self.assign(to: \.wrappedValue, on: failablePublished)

    }
}

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
