//
//  FirstInputViewController.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import UIKit

final class FirstInputViewController: UIViewController {

    var inputAdapter: FirstInputAdapter
    weak var coordinatorDelegate: InputCoordinatorDelegate?
    
    private init(inputAdapter: FirstInputAdapter, coordinatorDelegate: InputCoordinatorDelegate? = nil) {
        self.inputAdapter = inputAdapter
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Builder

extension FirstInputViewController {
    
    static func build(with delegate: InputCoordinatorDelegate,and adapter: FirstInputAdapter) -> FirstInputViewController {
        FirstInputViewController(inputAdapter: adapter, coordinatorDelegate: delegate)
    }
}
