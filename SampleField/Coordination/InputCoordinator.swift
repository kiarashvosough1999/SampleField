//
//  InputCoordinator.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine

protocol InputCoordinatorDelegate: AnyObject {
    
    var presentPopUpSubject: InFailablePassThroughSubject<Void> { get }
    
    var dismissPresentedViewSubject: InFailablePassThroughSubject<Bool> { get }
}

final class InputCoordinator: BaseCoordinator, InputCoordinatorDelegate {
    
    var dismissPresentedViewSubject: InFailablePassThroughSubject<Bool> = InFailablePassThroughSubject<Bool>()
    
    var presentPopUpSubject: InFailablePassThroughSubject<Void> = InFailablePassThroughSubject<Void>()
    
    fileprivate var cancelables = Set<AnyCancellable>()
    
    override func start() {
        let view = FirstInputViewController.build(with: self, and: serviceContainer.getService()!)
        navigationController?.pushViewController(view, animated: false)
        
        startObservingDelegate()
    }
    
    fileprivate func startObservingDelegate() {
        presentPopUpSubject
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.presentSecondInputView()
            }
            .store(in: &cancelables)
        
        dismissPresentedViewSubject.sink { shouldAnimate in
            self.dismissPresentedView(animated: shouldAnimate)
        }
        .store(in: &cancelables)
    }
    
    fileprivate func dismissPresentedView(animated: Bool) {
        navigationController?.presentedViewController?.dismiss(animated: animated, completion: nil)
    }
    
    fileprivate func presentSecondInputView() {
        let controller = SecondInputViewController.build(with: self,
                                                         and: serviceContainer.getService()!)
        let detailsTransitioningDelegate = InteractiveModalTransitioningDelegate()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = detailsTransitioningDelegate
        self.navigationController?.present(controller,
                                           animated: true,
                                           completion: nil)
    }
}
