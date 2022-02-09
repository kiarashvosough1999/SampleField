//
//  PersistenceStorageFetchPort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

protocol PersistenceStorageFetchPort {
    func fetchAll<T>() throws -> [T] where T: NSMangedObjectConvertible
}
