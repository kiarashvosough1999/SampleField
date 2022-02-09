//
//  AppCoordinator.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import UIKit

final class AppCoordinator: BaseCoordinator {
    
    let window: UIWindow?
    
    init(window: UIWindow?, serviceContainer: ServiceLocator) {
        self.window = window
        super.init(serviceContainer: serviceContainer)
    }
    
    override func start() {
        guard let window = window else { return }
        
        let navigationController = UINavigationController()
        
        let inputCoorinator = InputCoordinator(navigationController: navigationController,
                                                serviceContainer: serviceContainer)
        
        inputCoorinator.$isCompleted.byWrapping(self) { strongSelf in
            strongSelf.$isCompleted.execute()
        }
        
        store(inputCoorinator)
        inputCoorinator.start()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
