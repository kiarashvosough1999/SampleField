//
//  PersistenceStorageInsertPort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine
import CoreData

protocol PersistenceStorageInsertPort {
    
    func insertSync<T>(_ object: T, on context: ContextName) -> Result<T,FieldError> where T: NSMangedObjectConvertible
    
    func insert<T>(_ object: T, on context: ContextName) -> AnyPublisher<T,FieldError> where T: NSMangedObjectConvertible
}
