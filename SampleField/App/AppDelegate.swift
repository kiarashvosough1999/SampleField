//
//  AppDelegate.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import UIKit
import CoreData

final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerServices()
        return true
    }
    
    fileprivate func registerServices() {
        ServiceContainer.initial()
        
        ServiceContainer.main.addService { _ in
            CoreDataPersistenceStorageAdapter()
        }
        .implements(PersistenceStoragePort.self)
        .implements(PersistenceStorageInsertPort.self)
        .implements(PersistenceStorageFetchPort.self)
        .implements(PersistenceStorageDeletePort.self)
        .implements(PersistenceStorageObserverPort.self)
        .implements(PersistenceStorageUpdatePort.self)
        
        ServiceContainer.main.addService { res in
            FirstInputServiceImpl(storagePort: res.getService()!)
        }
        .implements(FirstInputServicePort.self)
        
        ServiceContainer.main.addService { res in
            FirstInputAdapter(firstInputServicePort: res.getService()!)
        }
        .implements(FirstInputAdapterDelegate.self)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return SceneManager(with: options).generateUISceneConfiguration()
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

