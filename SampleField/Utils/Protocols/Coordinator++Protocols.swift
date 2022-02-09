//
//  Coordinator++Protocols.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    
    var isCompleted: (() -> ())? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController? { get set }
    var serviceContainer: ServiceLocator { get }
    
    func start()
}

extension Coordinator {
    
    func free(_ child: Coordinator?) {
        childCoordinators.removeAll { $0 === child }
    }
    
    func store(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
}

protocol AlertableCoordination: AnyObject {
    func presentAlert(title: String,
                      message: String,
                      actionBtnTitle: String)
}

class BaseCoordinator: NSObject, Coordinator {
    
    var serviceContainer: ServiceLocator
    var navigationController: UINavigationController?
    var childCoordinators : [Coordinator] = []
    
    @MainQueue var isCompleted: (() -> ())?
    
    init(navigationController: UINavigationController? = nil, serviceContainer: ServiceLocator) {
        self.navigationController = navigationController
        self.serviceContainer = serviceContainer
        super.init()
        self.navigationController?.delegate = self
    }
    
    func start() {
        fatalError("Children should implement `start`.")
    }
}

extension BaseCoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {}

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {}

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask { .all }

    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation { .portraitUpsideDown }

    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? { nil }

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? { nil }
}
