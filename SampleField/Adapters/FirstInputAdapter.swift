//
//  FirstInputAdapter.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine

protocol FirstInputAdapterDelegate: AnyObject {
    
    var textFieldReplacementStringDelegatePublisher: PassthroughSubject<(String?, NSRange, String), Never> { get }
    
    var popUpButtonVisibilityStatePublisher: AnyPublisher<Bool,Never> { get }
    
    var textFieldTextPublisher: AnyPublisher<String,Never> { get }
}

// this class acts as ViewModel
final class FirstInputAdapter {
    
    // MARK: - Button State
    
    enum FirstInputButtonState {
        
        case canPopUp
        case canNotPopUp
        
        var canBeEnabled: Bool {
            switch self {
            case .canPopUp:
                return true
            case .canNotPopUp:
                return false
            }
        }
    }
    
    // MARK: - Bindings
    
    @CurrentValuePublished fileprivate var popUpButtonVisibilityState: Bool = false
    
    @CurrentValuePublished fileprivate var textInputModel: FirstInputHolderModel = FirstInputHolderModel(input: "")
    
    fileprivate lazy var textFieldInputSubject = PassthroughSubject<(String?,NSRange,String),Never>()
    
    fileprivate var cancelables = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    
    fileprivate let firstInputServicePort: FirstInputServicePort
    
    init(firstInputServicePort: FirstInputServicePort) {
        self.firstInputServicePort = firstInputServicePort
        setupInitialDataFetch()
        startObservingDatabase()
    }
    
    fileprivate func setupInitialDataFetch() {
        
        let firstInitialPublisher = firstInputServicePort
            .fetchInitialValue()
            .replaceAnyInconsistency(with: .init(input: ""))
        
        firstInitialPublisher
            .assign(to: $textInputModel)
            .store(in: &cancelables)
        
        firstInitialPublisher
            .map { model -> FirstInputButtonState in
                if !model.input.isEmpty && model.input.count == 10 { return FirstInputButtonState.canPopUp }
                return FirstInputButtonState.canNotPopUp
            }
            .map { $0.canBeEnabled }
            .assign(to: $popUpButtonVisibilityState)
            .store(in: &cancelables)
    }
    
    fileprivate func startObservingDatabase() {
        
        firstInputServicePort
            .observeInputOnDB()
            .replaceAnyInconsistency(with: .init(input: ""))
            .assign(to: $textInputModel)
            .store(in: &cancelables)

        let textInputEventPublisher = textFieldInputSubject
            .compactMap { self.generateNewString(from: $0, range: $1, addedString: $2) }

        // handle button state when user enter a text
        textInputEventPublisher
            .map { model -> FirstInputButtonState in
                if !model.isEmpty && model.count == 10 && self.firstInputServicePort.checkForInputValidation(from: model) {
                    return FirstInputButtonState.canPopUp
                }
                return FirstInputButtonState.canNotPopUp
            }
            .map { $0.canBeEnabled }
            .assign(to: $popUpButtonVisibilityState)
            .store(in: &cancelables)

        // handle save or update text on db when it reaches the required length
        textInputEventPublisher
            .filter { $0.count == 10 }
            .flatMap { string in
                return self.firstInputServicePort
                    .handleInputCaching(input: self.textInputModel.clone(by: \.input, to: string))
                    .replaceAnyInconsistency(with: .init(input: ""))
                    .eraseToAnyPublisher()
            }
            .assign(to: $textInputModel)
            .store(in: &cancelables)
        
        // handle delete text on db when it reaches the zeo length
        textInputEventPublisher
            .filter { $0.count == 0 }
            .flatMap { string in
                return self.firstInputServicePort
                    .handleInputCaching(input: self.textInputModel.clone(by: \.input, to: string))
                    .replaceAnyInconsistency(with: .init(input: ""))
                    .eraseToAnyPublisher()
            }
            .assign(to: $textInputModel)
            .store(in: &cancelables)
    }
}

// MARK: - FirstInputAdapter Delegate

extension FirstInputAdapter: FirstInputAdapterDelegate {
    
    var textFieldTextPublisher: AnyPublisher<String, Never> {
        $textInputModel
            .subject
            .map(\.input)
            .eraseToAnyPublisher()
    }
    
    var popUpButtonVisibilityStatePublisher: AnyPublisher<Bool, Never> {
        $popUpButtonVisibilityState
            .subject
            .eraseToAnyPublisher()
    }
    
    var textFieldReplacementStringDelegatePublisher: PassthroughSubject<(String?, NSRange, String), Never> {
        textFieldInputSubject
    }
    
    fileprivate func generateNewString(from lastString: String?, range: NSRange, addedString: String) -> String? {
        if let text = lastString, let newRange = text.range(from: range)  {
            return text.replacingCharacters(in: newRange, with: addedString)
        }
        return nil
    }
}
