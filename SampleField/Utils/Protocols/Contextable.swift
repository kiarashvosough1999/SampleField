//
//  Contextable.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import CoreData

enum ContextName: String {
    case main
}

protocol Contextable {
    
    associatedtype Context
    
    var contextPool: [ContextName: Context] { get }
    
    var mainContext: Context { get }
    
    func getContext(with name: String) throws -> Context
    
    func getContext(with identifier: ContextName) throws -> Context
}

extension Contextable where Context == NSManagedObjectContext {
    
    func getContext(with name: String) throws -> Context {
        
        guard let identifier = ContextName(rawValue: name) else { throw ContextableError.ContextNameNotFound(name: name) }
        
        guard let context = contextPool[identifier] else { throw ContextableError.ContextNotFound(name: name) }
        
        return context
    }
    
    func getContext(with identifier: ContextName) throws -> Context {
        guard let context = contextPool[identifier] else { throw ContextableError.ContextNotFound(name: identifier.rawValue) }
        
        return context
    }
    
    func get<T,M>(object: T, with context: Context) throws -> M? where T: NSMangedObjectConvertible {
        guard
            let uri = URL(string: object.identifier),
            let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else
            {
                return nil
            }
        
        do {
            return try context.existingObject(with: objectID) as? M
        } catch {
            throw FieldError.dbError(reason: .CannotFindObject)
        }
    }
}

// MARK: - Error

enum ContextableError: Error {
    case ContextNameNotFound(name: String)
    case ContextNotFound(name: String)
}

extension Error {
    
    var asContextableError: ContextableError? {
        self as? ContextableError
    }
    
    var asContextableErrorUnsafe: ContextableError {
        self as! ContextableError
    }

    func asContextableError(orFailWith message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> ContextableError {
        guard let anyError = self as? ContextableError else {
            fatalError(message(), file: file, line: line)
        }
        return anyError
    }

    func asContextableError(or defaultAFError: @autoclosure () -> ContextableError) -> ContextableError {
        self as? ContextableError ?? defaultAFError()
    }
}
