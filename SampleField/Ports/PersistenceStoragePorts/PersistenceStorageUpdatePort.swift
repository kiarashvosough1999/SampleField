//
//  PersistenceStorageUpdatePort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

protocol PersistenceStorageUpdatePort {
    func update<T>(_ object: T) throws where T: NSMangedObjectConvertible
}
