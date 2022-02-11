//
//  Contextable.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import CoreData

protocol Contextable {
    
    associatedtype Context
    
    var contextPool: [ContextName: Context] { get }
    
    var mainContext: Context { get }
    
    func getContext(with name: String) -> Context?
    
    func getContext(with identifier: ContextName) -> Context?
}

enum ContextName: String {
    case main
}

extension Contextable where Context == NSManagedObjectContext {
    
    var mainContext: Context {
        contextPool[.main]!
    }
    
    func getContext(with name: String) -> Context? {
        
        guard let identifier = ContextName(rawValue: name) else { return nil }
        
        return contextPool[identifier]
    }
    
    func getContext(with identifier: ContextName) -> Context? {
        return contextPool[identifier]
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
