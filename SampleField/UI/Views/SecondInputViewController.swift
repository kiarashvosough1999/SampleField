//
//  SecondInputViewController.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import UIKit
import Combine

class SecondInputViewController: UIViewController, ConnectableView {
    
    // MARK: - Views
    
    fileprivate let viewMaker = ViewMaker()
    
    lazy var inputTextfield = viewMaker
        .textField
        .with(style: AppStyle.TextFields().simpleField())
    
    lazy var popUpCloseButton = viewMaker
        .button
        .with(style: AppStyle.Buttons().closePopUpButton())
    
    lazy var shuffleButton = viewMaker
        .button
        .with(style: AppStyle.Buttons().shuffleTextButton())
    
    
    fileprivate var inputAdapter: SecondInputAdapterDelegate

    fileprivate weak var coordinatorDelegate: InputCoordinatorDelegate?
    
    fileprivate var cancelables = Set<AnyCancellable>()
    
    fileprivate init(inputAdapter: SecondInputAdapterDelegate, coordinatorDelegate: InputCoordinatorDelegate? = nil) {
        self.inputAdapter = inputAdapter
        self.coordinatorDelegate = coordinatorDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addViews()
        activateConstraints()
        setupBindings()
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        inputTextfield.delegate = self
        
        shuffleButton.addAction(ActionPublished(actionSubject: inputAdapter.shuffleButtonAction),
                                for: .touchUpInside)
        
        popUpCloseButton
            .addAction(ActionPublished(actionSubject: coordinatorDelegate?.dismissPresentedViewSubject, signalValue: true),
                       for: .touchUpInside)
    }
    
    func setupBindings() {
        
    }
    
    func addViews() {
        view.addSubviews(views: inputTextfield, popUpCloseButton, shuffleButton)
    }

    @ConstraintBuilder
    func setupConstraints() -> [NSLayoutConstraint] {
        inputTextfield.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        inputTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        inputTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        inputTextfield.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/10)
        
        popUpCloseButton.topAnchor.constraint(equalTo: inputTextfield.bottomAnchor, constant: 20)
        popUpCloseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        popUpCloseButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10)
        popUpCloseButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/14)
        
        shuffleButton.topAnchor.constraint(equalTo: inputTextfield.bottomAnchor, constant: 20)
        shuffleButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10)
        shuffleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        shuffleButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/14)
    }
}

// MARK: - Builder

extension SecondInputViewController {
    
    static func build(with delegate: InputCoordinatorDelegate,and adapter: SecondInputAdapterDelegate) -> SecondInputViewController {
        SecondInputViewController(inputAdapter: adapter, coordinatorDelegate: delegate)
    }
}

extension SecondInputViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
}
