//
//  PersistenceStorageDeletePort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine

protocol PersistenceStorageDeletePort {
    func deleteAll<T>(_ objects: [T]) throws -> AnyPublisher<[T],FieldError> where T: NSMangedObjectConvertible
}
