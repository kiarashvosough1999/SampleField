//
//  PersistenceStorageObserverPort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import CoreData
import Combine

enum ChangeType: CaseIterable {
    
    case inserted, deleted, updated
    
    var userInfoKey: String {
        switch self {
        case .inserted: return "inserted"
        case .deleted: return "deleted"
        case .updated: return "updated"
        }
    }
}

enum ChangeResult<T> {
    case inserted([T])
    case deleted([T])
    case updated([T])
    
    var userInfoKey: String {
        switch self {
        case .inserted: return NSInsertedObjectIDsKey
        case .deleted: return NSDeletedObjectIDsKey
        case .updated: return NSUpdatedObjectIDsKey
        }
    }
    
    var resuleValues: [T] {
        switch self {
        case .inserted(let array):
            return array
        case .deleted(let array):
            return array
        case .updated(let array):
            return array
        }
    }
    
    static func buildResult(type: ChangeType, results:[T]) -> Self {
        switch type {
        case .inserted:
            return .inserted(results)
        case .deleted:
            return .deleted(results)
        case .updated:
            return .updated(results)
        }
    }
}

struct ChangeResultHolder<T>  {
    
    let inserted: [T]
    let deleted: [T]
    let updated: [T]
    
    init(inserted: [T] = [], deleted: [T] = [], updated: [T] = []) {
        self.inserted = inserted
        self.deleted = deleted
        self.updated = updated
    }
    
    var combinded: [T] {
        inserted + deleted + updated
    }
    
    func combined<V>(sortedBy keyPath: KeyPath<T,V>) -> [T] where V: Comparable {
        (inserted + deleted + updated).sorted { f, s in
            return f[keyPath: keyPath] > s[keyPath: keyPath]
        }
    }
}

protocol PersistenceStorageObserverPort {
    
    func publisher<T>(_ object: T.Type, changeType: ChangeType) -> AnyPublisher<ChangeResult<T>,FieldError> where T : NSMangedObjectConvertible
    
    func publisher<T>(_ object: T.Type, changeTypes: [ChangeType]) -> AnyPublisher<ChangeResultHolder<T>,FieldError> where T : NSMangedObjectConvertible
}
