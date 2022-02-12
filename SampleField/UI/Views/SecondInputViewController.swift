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
    
    lazy var inputLabel = viewMaker
        .textField
        .with(style: AppStyle.Labels().simpleLabel())
    
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
        
        title = "Shuffler"
        
        inputLabel.delegate = self
        
        addDoneNavBarButton()
    }
    
    fileprivate func addDoneNavBarButton() {
        let doneButton = UIBarButtonItem(title: "DONE",
                                         primaryAction: ActionPublished(actionSubject: coordinatorDelegate?.dismissPresentedViewSubject, signalValue: true))
        
        navigationItem.rightBarButtonItems = [doneButton]
    }
    
    func setupBindings() {
        shuffleButton
            .addAction(ActionPublished(actionSubject: inputAdapter.shuffleButtonAction),
                       for: .touchUpInside)
        
        popUpCloseButton
            .addAction(ActionPublished(actionSubject: coordinatorDelegate?.dismissPresentedViewSubject, signalValue: true),
                       for: .touchUpInside)
        
        shuffleButton
            .addAction(ActionPublished(actionSubject: inputAdapter.shuffleButtonAction),
                       for: .touchUpInside)
        
        inputAdapter
            .textLabelPublisher
            .assign(to: \.orEmptyText, on: inputLabel)
            .store(in: &cancelables)
    }
    
    func addViews() {
        view.addSubviews(views: inputLabel, popUpCloseButton, shuffleButton)
    }
    
    @ConstraintBuilder
    func setupConstraints() -> [NSLayoutConstraint] {
        inputLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        inputLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        inputLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        inputLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/10)
        
        popUpCloseButton.topAnchor.constraint(equalTo: inputLabel.bottomAnchor, constant: 20)
        popUpCloseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        popUpCloseButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10)
        popUpCloseButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/14)
        
        shuffleButton.topAnchor.constraint(equalTo: inputLabel.bottomAnchor, constant: 20)
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
