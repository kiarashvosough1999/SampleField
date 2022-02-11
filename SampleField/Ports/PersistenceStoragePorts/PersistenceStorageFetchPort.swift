//
//  PersistenceStorageFetchPort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine
import CoreData

protocol PersistenceStorageFetchPort {
    
    func fetchAll<T>(on context: ContextName) -> Result<[T],FieldError> where T: NSMangedObjectConvertible
    
    func fetchOne<T>(with identifier: String, on context: ContextName) -> Result<T,FieldError> where T : NSMangedObjectConvertible
    
    func fetchOne<T>(type: T.Type, on context: ContextName) -> AnyPublisher<T,FieldError> where T : NSMangedObjectConvertible
}
