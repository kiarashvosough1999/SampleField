//
//  CoreDataPersistenceStorageAdapterMock.swift
//  SampleFieldTests
//
//  Created by Kiarash Vosough on 2/10/22.
//

import Foundation
import CoreData
@testable import SampleField

final class CoreDataPersistenceStorageAdapterMock: CoreDataPersistenceStorageAdapter {
    
    init() {
        let persistentStoredescription = NSPersistentStoreDescription()
        persistentStoredescription.type = NSInMemoryStoreType
        let container = NSPersistentContainer(name: "SampleField")
        container.persistentStoreDescriptions = [persistentStoredescription]
        super.init(with: container)
    }
}
