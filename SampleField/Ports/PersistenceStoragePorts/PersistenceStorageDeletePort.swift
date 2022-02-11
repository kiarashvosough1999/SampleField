//
//  PersistenceStorageDeletePort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine
import CoreData

protocol PersistenceStorageDeletePort {
    
    func deleteAll<T>(_ objects: [T], on context: ContextName) -> AnyPublisher<[T],FieldError> where T: NSMangedObjectConvertible
    
    func deleteOne<T>(_ object: T, on context: ContextName) -> AnyPublisher<T,FieldError> where T: NSMangedObjectConvertible
}
