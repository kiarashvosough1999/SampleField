//
//  FieldError.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

enum FieldError: Error {
    
    case dbError(reason: DBError)
    case selfFoundNil
    
    enum DBError: Error {
        case ValuesFoundNil(propertyNames:[String] = [])
        case CannotCreate
        case CannotFindObject
        case WriteContextNotExist
        case ReadContextNotExist
        case ContextNotExist(reason: ContextableError)
        case ContextDealocated
        case CannotFetch
        case CannotFetchInObserveMode
        case CannotDelete
        case CannotSave
        case CannotUpdate
        case CannotMap
        case CannotSetRelationShip
        case CannotDetectChanges(for: ChangeType)
        case InvalidObjectID(String)
        case unknown(Error?)

    }
}

extension Error {
    
    var asFPError: FieldError? {
        self as? FieldError
    }
    
    var asFPErrorUnsafe: FieldError {
        self as! FieldError
    }

    func asFieldError(orFailWith message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> FieldError {
        guard let anyError = self as? FieldError else {
            fatalError(message(), file: file, line: line)
        }
        return anyError
    }

    func asFPError(or defaultAFError: @autoclosure () -> FieldError) -> FieldError {
        self as? FieldError ?? defaultAFError()
    }
}
