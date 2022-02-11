//
//  PersistenceStoragePort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import CoreData

protocol PersistenceStoragePort: PersistenceStorageInsertPort,
                                 PersistenceStorageDeletePort,
                                 PersistenceStorageUpdatePort,
                                 PersistenceStorageFetchPort,
                                 PersistenceStorageObserverPort {}
