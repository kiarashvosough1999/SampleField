//
//  PersistenceStorageAdapter.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import CoreData
import Combine

final class PersistenceStorageAdapter {
    
    private var container: NSPersistentContainer {
        didSet {
            loadStore()
        }
    }
    
    private func loadStore() {
        container.loadPersistentStores { storeDesription, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
    }
    
    init(with container: NSPersistentContainer = NSPersistentContainer(name: "SampleField")) {
        self.container = container
        container.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
        loadStore()
    }
    
    // I did not impelement background context as it may required more time to implement and handle the changes
    // the whole project use main context, although it is not the rigth way
    private lazy var mainContext: NSManagedObjectContext = {
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.undoManager = nil
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return container.viewContext
    }()
    
    fileprivate func get<T,M>(object: T, with context: NSManagedObjectContext) throws -> M? where T: NSMangedObjectConvertible {
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

// MARK: - Insert Port

extension PersistenceStorageAdapter: PersistenceStorageInsertPort {
    
    func insert<T>(_ object: T) throws where T : NSMangedObjectConvertible {
        var _error: FieldError?
        var managedObject: T.NSManagedObjectType!
        mainContext.performAndWait { [unowned mainContext] in
            
            managedObject = T.NSManagedObjectType(context: mainContext)
            if managedObject.from(object: object).not {
                _error = .dbError(reason: .CannotCreate)
                return
            }
            
            do {
                try mainContext.save()
            } catch {
                print(error)
                _error = .dbError(reason: .CannotSave)
            }
        }
        if let _error = _error { throw _error }
    }
}

// MARK: - Update Port

extension PersistenceStorageAdapter: PersistenceStorageUpdatePort {
    
    func update<T>(_ object: T) throws where T : NSMangedObjectConvertible {
        var _error: FieldError?
        mainContext.performAndWait { [unowned mainContext] in
            do {
                guard let managedObject: T.NSManagedObjectType = try get(object: object, with: mainContext) else {
                    _error = .dbError(reason: .CannotFetch)
                    return
                }
                
                if managedObject.from(object: object).not {
                    _error = .dbError(reason: .CannotCreate)
                    return
                }
                try mainContext.save()
            } catch {
                _error = error.asFPError(or: .dbError(reason: .CannotSave))
            }
        }
        if let _error = _error { throw _error }
    }
}

// MARK: - Fetch

extension PersistenceStorageAdapter: PersistenceStorageFetchPort {
    
    func fetchAll<T>() throws -> [T] where T: NSMangedObjectConvertible {
        var items: [T] = []
        var _error: FieldError?
        mainContext.performAndWait { [unowned mainContext] in
            
            let request = NSFetchRequest<T.NSManagedObjectType>(entityName: String(describing: T.NSManagedObjectType.self))
            request.returnsObjectsAsFaults = false
            
            do {
                let managedObjects = try mainContext.fetch(request)
                items = try managedObjects.compactMap { try $0.toObject() }
            } catch {
                _error = error.asFPError(or: .dbError(reason: .CannotFetch))
            }
        }
        if let _error = _error { throw _error }
        return items
    }
}

// MARK: - Observers

extension PersistenceStorageAdapter: PersistenceStorageDeletePort {
    
    func deleteAll<T>(_ objects: [T]) throws -> AnyPublisher<[T],FieldError> where T: NSMangedObjectConvertible {
        return Deferred { [unowned self] in
            Future { [unowned self] promise in
                self.mainContext.performAndWait { [unowned self] in
                    do {
                        let managedObjects: [T.NSManagedObjectType] = try objects.compactMap({ try self.get(object: $0, with: mainContext) })
                        managedObjects.forEach { mainContext.delete($0) }
                        try self.mainContext.save()
                        promise(.success(objects))
                    } catch {
                        promise(.failure(error.asFPError(or: .dbError(reason: .CannotDelete))))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
}

extension PersistenceStorageAdapter: PersistenceStorageObserverPort {
    
    func publisher<T>(_ object: T.Type, changeTypes: [ChangeType]) -> AnyPublisher<[([T], ChangeType)],FieldError> where T : NSMangedObjectConvertible {
        
        let notification = NSManagedObjectContext.didMergeChangesObjectIDsNotification
        return NotificationCenter
            .default
            .publisher(for: notification, object: mainContext)
            .tryCompactMap { notification in
                return try changeTypes.compactMap { type -> ([T], ChangeType)? in
                    guard let changes = notification.userInfo?[type.userInfoKey] as? Set<NSManagedObjectID> else {
                        throw FieldError.dbError(reason: .CannotDetectChanges(for: type))
                    }
                    
                    let objects = changes
                        .filter { $0.entity == T.NSManagedObjectType.entity() }
                        .compactMap { self.mainContext.object(with: $0) as? T }
                    return (objects, type)
                }
            }
            .mapError { $0.asFPErrorUnsafe }
            .eraseToAnyPublisher()
    }
}
