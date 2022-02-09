//
//  PersistenceStorageObserverPort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import CoreData
import Combine

enum ChangeType {
    case inserted, deleted, updated
    
    var userInfoKey: String {
        switch self {
        case .inserted: return NSInsertedObjectIDsKey
        case .deleted: return NSDeletedObjectIDsKey
        case .updated: return NSUpdatedObjectIDsKey
        }
    }
}

protocol PersistenceStorageObserverPort {
    func publisher<T>(_ object: T.Type, changeTypes: [ChangeType]) -> AnyPublisher<[([T], ChangeType)],FieldError> where T : NSMangedObjectConvertible
}
