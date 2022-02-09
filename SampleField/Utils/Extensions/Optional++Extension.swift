//
//  Optional++Extension.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

extension Optional {

    enum OptionalError: Error {
        case Nil
        case callBackNil
        case predicateNotMatched
        case expectationFailed
    }

    var isNil: Bool {
        return self == nil
    }

    var isNotNil: Bool {
        return self != nil
    }

    func matching(_ predicate: (Wrapped) -> Bool) -> Wrapped? {
        guard let value = self else { return nil }

        guard predicate(value) else { return nil }

        return value
    }

    func matching(_ predicate: (Wrapped) -> Bool) throws -> Wrapped {
        guard let value = self else { throw OptionalError.Nil }

        guard predicate(value) else { throw OptionalError.predicateNotMatched }

        return value
    }

    func expect(_ message: String) -> Wrapped {
        precondition(self != nil, message)
        return self!
    }

    func expectOrThrow() throws -> Wrapped {
        guard let value = self else { throw OptionalError.expectationFailed }
        return value
    }

    func on(some: () throws -> Void) rethrows {
        if self != nil { try some() }
    }

    func on(_ some: (Wrapped) throws -> Void) rethrows {
        if self != nil { try some(self!) }
    }

    func on(some: (Wrapped) throws -> Void, none: () throws -> Void) rethrows {
        if let self = self {
            try some(self)
        } else {
            try none()
        }
    }

    func compactMap<T>(some: (Wrapped) throws -> T, none: () throws -> T) rethrows -> T {
        if let self = self {
            return try some(self)
        } else {
            return try none()
        }
    }

    func onNil(_ none: () throws -> Void) rethrows {
        if self == nil { try none() }
    }

    func or(_ default: Wrapped) -> Wrapped {
        return self ?? `default`
    }

    func or(else: @autoclosure () -> Wrapped) -> Wrapped {
        return self ?? `else`()
    }

    func or(else: () -> Wrapped) -> Wrapped {
        return self ?? `else`()
    }

    func or(throw exception: Error) throws -> Wrapped {
        guard let unwrapped = self else { throw exception }
        return unwrapped
    }
    
    mutating func toggleNil() {
        self = nil
    }
}

extension Optional where Wrapped: Collection {
    
    var isEmpty: Bool {
        guard case let .some(val) = self else {
            return true
        }
        return val.isEmpty
    }
}
