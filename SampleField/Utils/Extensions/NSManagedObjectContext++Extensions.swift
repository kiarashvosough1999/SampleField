//
//  NSManagedObjectContext++Extensions.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import CoreData

extension NSManagedObjectContext {
    
    func safeObject<T>(with objectID: NSManagedObjectID) throws -> T where T: NSManagedObject {
        guard let object = object(with: objectID) as? T else { throw NSManagedObjectContextError.objectCastFailed }
        if object.isFault { throw NSManagedObjectContextError.objectNotFound }
        return object
    }
    
    func perform(_ safeClosure: @escaping (Result<NSManagedObjectContext,NSManagedObjectContextError>) -> Void) {
        self.perform { [weak self] in
            guard let strongSelf = self else { safeClosure(.failure(.contextFoundNil)); return }
            safeClosure(.success(strongSelf))
        }
    }
    
    func performAndWait(_ safeClosure: (Result<NSManagedObjectContext,NSManagedObjectContextError>) -> Void) {
        self.performAndWait { [weak self] in
            guard let strongSelf = self else { safeClosure(.failure(.contextFoundNil)); return }
            safeClosure(.success(strongSelf))
        }
    }
}

enum NSManagedObjectContextError: Error {
    case contextFoundNil
    case objectNotFound
    case objectCastFailed
}
extension Error {
    
    var asNSManagedObjectContextError: NSManagedObjectContextError? {
        self as? NSManagedObjectContextError
    }
    
    var asNSManagedObjectContextErrorUnsafe: NSManagedObjectContextError {
        self as! NSManagedObjectContextError
    }
    
    func asNSManagedObjectContextError(orFailWith message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> NSManagedObjectContextError {
        guard let anyError = self as? NSManagedObjectContextError else {
            fatalError(message(), file: file, line: line)
        }
        return anyError
    }
    
    func asNSManagedObjectContextError(or defaultAFError: @autoclosure () -> NSManagedObjectContextError) -> NSManagedObjectContextError {
        self as? NSManagedObjectContextError ?? defaultAFError()
    }
}
