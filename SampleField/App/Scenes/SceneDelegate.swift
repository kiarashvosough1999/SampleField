//
//  SceneDelegate.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import UIKit

final class MainAppSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var appCoordinator: Coordinator?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        appCoordinator = AppCoordinator(window: UIWindow(windowScene: scene),
                                        serviceContainer: ServiceContainer.main)
        appCoordinator?.start()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

