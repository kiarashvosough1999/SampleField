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
}

final class InputCoordinator: BaseCoordinator, InputCoordinatorDelegate {
    
    var presentPopUpSubject: InFailablePassThroughSubject<Void> = InFailablePassThroughSubject<Void>()
    
    fileprivate var cancelables = Set<AnyCancellable>()
    
    override func start() {
        let view = FirstInputViewController.build(with: self, and: serviceContainer.getService()!)
        navigationController?.pushViewController(view, animated: false)
        
        startObservingDelegate()
    }
    
    fileprivate func startObservingDelegate() {
        presentPopUpSubject.sink { _ in
            print("dasdsadsad")
        }.store(in: &cancelables)
    }
}
