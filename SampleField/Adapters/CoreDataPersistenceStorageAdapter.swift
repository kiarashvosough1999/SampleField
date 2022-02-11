//
//  PersistenceStorageAdapter.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import CoreData
import Combine

// FetchRequest is not yet supportes, indeed it was not needed now
class CoreDataPersistenceStorageAdapter: Contextable {
    
    typealias Context = NSManagedObjectContext
    
    var contextPool: [ContextName : NSManagedObjectContext] {
        [
            .main : mainContext
        ]
    }
    
    var container: NSPersistentContainer
    
    init(with container: NSPersistentContainer = NSPersistentContainer(name: "SampleField")) {
        self.container = container
        container.persistentStoreDescriptions.first?.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions.first?.shouldMigrateStoreAutomatically = true
        container.loadPersistentStores { storeDesription, error in
            guard error == nil else {
                fatalError("Unresolved error \(error!)")
            }
        }
    }
    
    // I did not impelement background context as it may required more time to implement and handle the changes
    // the whole project use main context, although it is not the rigth way
    lazy var currentMainContext: NSManagedObjectContext = {
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.undoManager = nil
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return container.viewContext
    }()
}

// MARK: - Insert Port

extension CoreDataPersistenceStorageAdapter: PersistenceStorageInsertPort {
    
    func insert<T>(_ object: T, on context: ContextName = .main) -> AnyPublisher<T,FieldError> where T: NSMangedObjectConvertible {
        Deferred { [weak self] in
            Future { [weak self] promise in
                
                guard let strongSelf = self else {
                    promise(.failure(.selfFoundNil))
                    return
                }
                do {
                    let context = try strongSelf.getContext(with: context)
                    
                    context.perform { safeContext in
                        
                        guard let context = try? safeContext.get() else {
                            promise(.failure(.dbError(reason: .ContextDealocated)))
                            return
                        }
                        
                        let managedObject = T.NSManagedObjectType(context: context)
                        if managedObject.from(object: object).not {
                            promise(.failure(.dbError(reason: .CannotCreate)))
                            return
                        }
                        
                        do {
                            try context.save()
                            var newobject = object
                            newobject.identifier = managedObject.identifier
                            promise(.success(newobject))
                        } catch {
                            promise(.failure(.dbError(reason: .CannotSave)))
                        }
                    }
                } catch let error as ContextableError {
                    promise(.failure(.dbError(reason: .ContextNotExist(reason: error))))
                } catch {
                    promise(.failure(.dbError(reason: .unknown(error))))
                }
                
            }
        }.eraseToAnyPublisher()
    }
    
    func insertSync<T>(_ object: T, on context: ContextName = .main) -> Result<T, FieldError> where T : NSMangedObjectConvertible {
        var _error: FieldError?
        var managedObject: T.NSManagedObjectType!
        var newobject = object
        
        do {
            let context = try getContext(with: context)
            
            context.performAndWait { safeContext in
                do {
                    let context = try safeContext.get()
                    
                    managedObject = T.NSManagedObjectType(context: context)
                    
                    if managedObject.from(object: object).not {
                        _error = .dbError(reason: .CannotCreate)
                        return
                    }
                    
                    do {
                        try context.save()
                        newobject.identifier = managedObject.identifier
                    } catch {
                        _error = .dbError(reason: .CannotSave)
                    }
                    
                } catch let error as ContextableError {
                    _error = .dbError(reason: .ContextNotExist(reason: error))
                } catch {
                    _error = .dbError(reason: .unknown(error))
                }
                
            }
        } catch {
            _error = .dbError(reason: .ContextNotExist(reason: error.asContextableErrorUnsafe))
        }
        
        if let _error = _error { return .failure(_error) }
        
        return .success(newobject)
    }
}

// MARK: - Update Port

extension CoreDataPersistenceStorageAdapter: PersistenceStorageUpdatePort {
    
    func update<T>(_ object: T, on context: ContextName = .main) -> AnyPublisher<T,FieldError> where T: NSMangedObjectConvertible {
        Deferred { [weak self] in
            Future { [weak self] promise in
                
                guard let strongSelf = self else {
                    promise(.failure(.selfFoundNil))
                    return
                }
                
                do {
                    let context = try strongSelf.getContext(with: context)
                    
                    context.perform { [unowned strongSelf] safeContext in
                        do {
                            let context = try safeContext.get()
                            
                            guard let managedObject: T.NSManagedObjectType = try strongSelf.get(object: object, with: context) else {
                                promise(.failure(.dbError(reason: .CannotFetch)))
                                return
                            }
                            
                            if managedObject.from(object: object).not {
                                promise(.failure(.dbError(reason: .CannotCreate)))
                                return
                            }
                            try context.save()
                            promise(.success(object))
                        } catch let error as ContextableError {
                            promise(.failure(.dbError(reason: .ContextNotExist(reason: error))))
                        } catch {
                            promise(.failure(error.asFPError(or: .dbError(reason: .CannotSave))))
                        }
                    }
                    
                } catch {
                    promise(.failure(.dbError(reason: .ContextNotExist(reason: error.asContextableErrorUnsafe))))
                }
                
            }
        }.eraseToAnyPublisher()
    }
    
    func update<T>(_ object: T, on context: ContextName = .main) -> Result<T,FieldError> where T : NSMangedObjectConvertible {
        
        var _error: FieldError?
        do {
            let context = try getContext(with: context)
            
            context.performAndWait { safeContext in
                do {
                    let context = try safeContext.get()
                    
                    guard let managedObject: T.NSManagedObjectType = try get(object: object, with: context) else {
                        _error = .dbError(reason: .CannotFetch)
                        return
                    }
                    
                    if managedObject.from(object: object).not {
                        _error = .dbError(reason: .CannotUpdate)
                        return
                    }
                    try context.save()
                } catch let error as ContextableError {
                    _error = .dbError(reason: .ContextNotExist(reason: error))
                } catch {
                    _error = error.asFPError(or: .dbError(reason: .CannotUpdate))
                }
            }
        } catch {
            _error = .dbError(reason: .ContextNotExist(reason: error.asContextableErrorUnsafe))
        }
        
        if let _error = _error { return .failure(_error) }
        
        return .success(object)
    }
}

// MARK: - Fetch

extension CoreDataPersistenceStorageAdapter: PersistenceStorageFetchPort {
    
    func fetchOne<T>(with identifier: String, on context: ContextName = .main) -> Result<T,FieldError> where T : NSMangedObjectConvertible {
        var _error: FieldError?
        
        do {
            let context = try self.getContext(with: context)
            
            guard let uri = URL(string: identifier),
                  let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: uri) else {
                      return .failure(FieldError.dbError(reason: .InvalidObjectID(identifier)))
                  }
            
            var item: T!
            
            context.performAndWait { safeContext in
                do {
                    
                    let context = try safeContext.get()
                    
                    let managedObject: T.NSManagedObjectType = try context.safeObject(with: objectID)
                    
                    item = try managedObject.toObject()
                } catch let error as ContextableError {
                    _error = .dbError(reason: .ContextNotExist(reason: error))
                } catch {
                    _error = error.asFPError(or: .dbError(reason: .CannotFetch))
                }
            }
            
            return .success(item)
        } catch let error as ContextableError {
            _error = .dbError(reason: .ContextNotExist(reason: error))
        } catch {
            _error = .dbError(reason: .unknown(error))
        }
        
        return .failure(_error!)
    }
    
    func fetchOne<T>(type: T.Type, on context: ContextName = .main) -> AnyPublisher<T,FieldError> where T : NSMangedObjectConvertible {
        Deferred { [weak self] in
            Future { [weak self] promise in
                
                guard let strongSelf = self else {
                    promise(.failure(.selfFoundNil))
                    return
                }
                
                do {
                    let context = try strongSelf.getContext(with: context)
                    
                    context.perform { safeContext in
                        let request = NSFetchRequest<T.NSManagedObjectType>(entityName: String(describing: T.NSManagedObjectType.self))
                        request.returnsObjectsAsFaults = false
                        request.fetchLimit = 1
                        do {
                            let context = try safeContext.get()
                            
                            let managedObject = try context.fetch(request).first
                            guard let item: T = try managedObject?.toObject() else {
                                promise(.failure(.dbError(reason: .CannotFetch)))
                                return
                            }
                            promise(.success(item))
                        } catch let error as ContextableError {
                            promise(.failure(.dbError(reason: .ContextNotExist(reason: error))))
                        } catch {
                            promise(.failure(error.asFPError(or: .dbError(reason: .CannotFetch))))
                        }
                    }
                } catch let error as ContextableError {
                    promise(.failure(.dbError(reason: .ContextNotExist(reason: error))))
                } catch {
                    promise(.failure(.dbError(reason: .unknown(error))))
                }
                
                
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchAll<T>(on context: ContextName = .main) -> Result<[T],FieldError> where T: NSMangedObjectConvertible {
        
        var items: [T] = []
        var _error: FieldError?
        
        do {
            let context = try getContext(with: context)
            context.performAndWait { safeContext in
                
                let request = NSFetchRequest<T.NSManagedObjectType>(entityName: String(describing: T.NSManagedObjectType.self))
                request.returnsObjectsAsFaults = false
                
                do {
                    let context = try safeContext.get()
                    let managedObjects = try context.fetch(request)
                    items = try managedObjects.compactMap { try $0.toObject() }
                } catch let error as ContextableError {
                    _error = .dbError(reason: .ContextNotExist(reason: error))
                } catch {
                    _error = error.asFPError(or: .dbError(reason: .CannotFetch))
                }
            }
            return .success(items)
        } catch let error as ContextableError {
            _error = .dbError(reason: .ContextNotExist(reason: error))
        } catch {
            _error = .dbError(reason: .unknown(error))
        }
        
        return .failure(_error!)
    }
}

// MARK: - Delete

extension CoreDataPersistenceStorageAdapter: PersistenceStorageDeletePort {
    
    func deleteAll<T>(_ objects: [T], on context: ContextName = .main) -> AnyPublisher<[T],FieldError> where T: NSMangedObjectConvertible {
        
        Deferred { [weak self] in
            Future { [weak self] promise in
                
                guard let strongSelf = self else {
                    promise(.failure(.selfFoundNil))
                    return
                }
                
                do {
                    let context = try strongSelf.getContext(with: context)
                    
                    context.perform { [unowned strongSelf] safeContext in
                        do {
                            let context = try safeContext.get()
                            
                            let managedObjects: [T.NSManagedObjectType] = try objects
                                .compactMap { try strongSelf.get(object: $0, with: context) }
                            
                            managedObjects.forEach { context.delete($0) }
                            
                            try context.save()
                            
                            promise(.success(objects))
                            
                        } catch let error as ContextableError {
                            promise(.failure(.dbError(reason: .ContextNotExist(reason: error))))
                        } catch {
                            promise(.failure(.dbError(reason: .CannotSave)))
                        }
                    }
                    
                } catch let error as ContextableError {
                    promise(.failure(.dbError(reason: .ContextNotExist(reason: error))))
                } catch {
                    promise(.failure(.dbError(reason: .unknown(error))))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteOne<T>(_ object: T, on context: ContextName = .main) -> AnyPublisher<T,FieldError> where T: NSMangedObjectConvertible {
        Deferred { [weak self] in
            Future { [weak self] promise in
                
                guard let strongSelf = self else {
                    promise(.failure(.selfFoundNil))
                    return
                }
                
                do {
                    let context = try strongSelf.getContext(with: context)
                    
                    context.perform { [unowned strongSelf] safeContext in
                        do {
                            let context = try safeContext.get()
                            
                            guard let managedObject: T.NSManagedObjectType = try strongSelf.get(object: object, with: context) else {
                                promise(.failure(.dbError(reason: .CannotFindObject)))
                                return
                            }
                            
                            context.delete(managedObject)
                            
                            try context.save()
                            
                            promise(.success(object))
                            
                        } catch let error as ContextableError {
                            promise(.failure(.dbError(reason: .ContextNotExist(reason: error))))
                        } catch {
                            promise(.failure(.dbError(reason: .CannotSave)))
                        }
                    }
                } catch let error as ContextableError {
                    promise(.failure(.dbError(reason: .ContextNotExist(reason: error))))
                } catch {
                    promise(.failure(.dbError(reason: .unknown(error))))
                }
            }
        }.eraseToAnyPublisher()
    }
}

// MARK: - Observers

extension CoreDataPersistenceStorageAdapter: PersistenceStorageObserverPort {
    
    func publisher<T>(_ object: T.Type, changeType: ChangeType) -> AnyPublisher<ChangeResult<T>,FieldError> where T : NSMangedObjectConvertible {
        let notification = NSManagedObjectContext.didMergeChangesObjectIDsNotification
        return NotificationCenter
            .default
            .publisher(for: notification, object: mainContext)
            .tryCompactMap { notification in
                guard let changes = notification.userInfo?[changeType.userInfoKey] as? Set<NSManagedObjectID> else {
                    throw FieldError.dbError(reason: .CannotDetectChanges(for: changeType))
                }
                
                let objects = changes
                    .filter { $0.entity == T.NSManagedObjectType.entity() }
                    .compactMap { self.mainContext.object(with: $0) as? T }
                return ChangeResult.buildResult(type: changeType, results: objects)
            }
            .mapError { $0.asFPErrorUnsafe }
            .eraseToAnyPublisher()
    }
    
    func publisher<T>(_ object: T.Type, changeTypes: [ChangeType] = ChangeType.allCases) -> AnyPublisher<ChangeResultHolder<T>,FieldError> where T : NSMangedObjectConvertible {
        
        let notification = NSManagedObjectContext.didMergeChangesObjectIDsNotification
        return NotificationCenter
            .default
            .publisher(for: notification, object: mainContext)
            .tryCompactMap { notification in
                var inserted: [T] = []
                var deleted: [T] = []
                var updated: [T] = []
                
                func detectChanges(type: ChangeType) throws -> [T] {
                    guard let changes = notification.userInfo?[type.userInfoKey] as? Set<NSManagedObjectID> else {
                        throw FieldError.dbError(reason: .CannotDetectChanges(for: type))
                    }
                    
                    let objects = changes
                        .filter { $0.entity == T.NSManagedObjectType.entity() }
                        .compactMap { self.mainContext.object(with: $0) as? T }
                    return objects
                }
                
                if changeTypes.contains(.updated) {
                    updated = try detectChanges(type: .updated)
                }
                
                if changeTypes.contains(.inserted) {
                    inserted = try detectChanges(type: .inserted)
                }
                
                if changeTypes.contains(.deleted) {
                    deleted = try detectChanges(type: .deleted)
                }
                return ChangeResultHolder(inserted: inserted, deleted: deleted, updated: updated)
            }
            .mapError { $0.asFPErrorUnsafe }
            .eraseToAnyPublisher()
    }
}

extension CoreDataPersistenceStorageAdapter: PersistenceStoragePort {
    
    var mainContext: NSManagedObjectContext {
        currentMainContext
    }
}
