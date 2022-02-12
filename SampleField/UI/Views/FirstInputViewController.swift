//
//  FirstInputViewController.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import UIKit
import Combine

final class FirstInputViewController: UIViewController, ConnectableView {
    
    // MARK: - Views
    
    fileprivate let viewMaker = ViewMaker()
    
    lazy var inputTextfield = viewMaker
        .textField
        .with(style: AppStyle.TextFields().simpleField())
    
    lazy var popUpButton = viewMaker
        .button
        .with(style: AppStyle.Buttons().openPopUpButton())
    
    // MARK: - Life Cycle
    
    fileprivate var inputAdapter: FirstInputAdapterDelegate
    
    fileprivate weak var coordinatorDelegate: InputCoordinatorDelegate?
    
    fileprivate var cancelables = Set<AnyCancellable>()
    
    fileprivate init(inputAdapter: FirstInputAdapterDelegate, coordinatorDelegate: InputCoordinatorDelegate? = nil) {
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
        inputTextfield.delegate = self
        view.backgroundColor = .white
        
        /* old API popUpButton.addTarget(self, action: #selector(popUpButtonEvents), for: .touchUpInside) */
        
        popUpButton.addAction(ActionPublished(actionSubject: coordinatorDelegate?.presentPopUpSubject),
                              for: .touchUpInside)
    }
    
    func setupBindings() {
        inputAdapter
            .popUpButtonVisibilityStatePublisher
            .assign(to: \.isEnabled, on: popUpButton)
            .store(in: &cancelables)
        
        inputAdapter
            .popUpButtonVisibilityStatePublisher
            .map { $0 ? UIColor.blue : UIColor.gray }
            .assign(to: \.backgroundColor, on: popUpButton)
            .store(in: &cancelables)
        
        inputAdapter
            .textFieldTextPublisher
            .assign(to: \.orEmptyText, on: inputTextfield)
            .store(in: &cancelables)
    }
    
    func addViews() {
        view.addSubviews(views: inputTextfield, popUpButton)
    }
    
    @ConstraintBuilder
    func setupConstraints() -> [NSLayoutConstraint] {
        inputTextfield.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        inputTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        inputTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        inputTextfield.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/10)
        
        popUpButton.topAnchor.constraint(equalTo: inputTextfield.bottomAnchor, constant: 20)
        popUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        popUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        popUpButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/14)
        
    }
    
    /* old API
    @objc fileprivate func popUpButtonEvents(_ sender: Button) {
        coordinatorDelegate?.presentPopUpSubject.send(())
    }
    */
}

// MARK: - Builder

extension FirstInputViewController {
    
    static func build(with delegate: InputCoordinatorDelegate?,and adapter: FirstInputAdapterDelegate) -> FirstInputViewController {
        FirstInputViewController(inputAdapter: adapter, coordinatorDelegate: delegate)
    }
}

// MARK: - TextField Delegate

extension FirstInputViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        inputAdapter.textFieldReplacementStringDelegatePublisher.send((textField.text, range, string))
        return true
    }
}
