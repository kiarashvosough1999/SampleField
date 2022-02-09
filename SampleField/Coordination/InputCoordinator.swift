//
//  InputCoordinator.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

protocol InputCoordinatorDelegate: AnyObject {
    
}

final class InputCoordinator: BaseCoordinator {
    
    override func start() {
        navigationController?.pushViewController(ViewController(), animated: false)
    }
}

extension InputCoordinator: InputCoordinatorDelegate {
    
}
