//
//  FirstInputAdapter.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine

protocol FirstInputAdapterDelegate {
    
    var textFieldReplacementStringDelegatePublisher: InFailablePassThroughSubject<(String?, NSRange, String)> { get }
    
    var popUpButtonVisibilityStatePublisher: InFailableAnyPublisher<Bool> { get }
    
    var textFieldTextPublisher: InFailableAnyPublisher<String> { get }
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
    
    fileprivate lazy var textFieldInputSubject = InFailablePassThroughSubject<(String?,NSRange,String)>()
    
    fileprivate var cancelables = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    
    fileprivate let inputCachingServicePort: InputCachingServicePort
    
    fileprivate let inputValidationServicePort: InputValidationServicePort
    
    init(firstInputServicePort: InputCachingServicePort, inputValidationServicePort: InputValidationServicePort) {
        self.inputValidationServicePort = inputValidationServicePort
        self.inputCachingServicePort = firstInputServicePort
        setupInitialDataFetch()
        startObservingDatabase()
    }
    
    fileprivate func setupInitialDataFetch() {
        
        let firstInitialPublisher = inputCachingServicePort
            .fetchInitialValue()
            .replaceAnyInconsistency(with: .init(input: ""))
        
        firstInitialPublisher
            .assign(to: $textInputModel)
            .store(in: &cancelables)
        
        firstInitialPublisher
            .conditionalMap(if: {
                self.inputValidationServicePort.isFieldNotEmpty(input: $0.input) &&
                self.inputValidationServicePort.checkForInputValidation(from: $0.input)
            }, satisfied: FirstInputButtonState.canPopUp, else: FirstInputButtonState.canNotPopUp)
            .map { $0.canBeEnabled }
            .assign(to: $popUpButtonVisibilityState)
            .store(in: &cancelables)
    }
    

    
    fileprivate func startObservingDatabase() {
        
        inputCachingServicePort
            .observeInputOnDB()
            .replaceAnyInconsistency(with: .init(input: ""))
            .assign(to: $textInputModel)
            .store(in: &cancelables)

        let textInputEventPublisher = textFieldInputSubject
            .compactMap { self.generateNewString(from: $0, range: $1, addedString: $2) }

        // handle button state when user enter a text
        textInputEventPublisher
            .conditionalMap(if: {
                self.inputValidationServicePort.isFieldNotEmpty(input: $0) &&
                self.inputValidationServicePort.checkForInputValidation(from: $0)
            }, satisfied: FirstInputButtonState.canPopUp, else: FirstInputButtonState.canNotPopUp)
            .map { $0.canBeEnabled }
            .assign(to: $popUpButtonVisibilityState)
            .store(in: &cancelables)

        // handle save or update text on db when it reaches the required length
        textInputEventPublisher
            .filter { self.inputValidationServicePort.isInputLengthEnough(input: $0) }
            .flatMap { string in
                return self.inputCachingServicePort
                    .handleInsertOrUpdateInputCaching(input: self.textInputModel.clone(by: \.input, to: string))
                    .replaceAnyInconsistency(with: .init(input: ""))
                    .eraseToAnyPublisher()
            }
            .assign(to: $textInputModel)
            .store(in: &cancelables)
        
        // handle delete text on db when it reaches the zeo length
        textInputEventPublisher
            .filter { self.inputValidationServicePort.isInputLengthZero(input: $0) }
            .flatMap { string in
                return self.inputCachingServicePort
                    .handleDeleteInputCaching(input: self.textInputModel.clone(by: \.input, to: string))
                    .replaceAnyInconsistency(with: .init(input: ""))
                    .eraseToAnyPublisher()
            }
            .assign(to: $textInputModel)
            .store(in: &cancelables)
    }
}

// MARK: - FirstInputAdapter Delegate

extension FirstInputAdapter: FirstInputAdapterDelegate {
    
    var textFieldTextPublisher: InFailableAnyPublisher<String> {
        $textInputModel
            .subject
            .map(\.input)
            .eraseToAnyPublisher()
    }
    
    var popUpButtonVisibilityStatePublisher: InFailableAnyPublisher<Bool> {
        $popUpButtonVisibilityState
            .subject
            .eraseToAnyPublisher()
    }
    
    var textFieldReplacementStringDelegatePublisher: InFailablePassThroughSubject<(String?, NSRange, String)> {
        textFieldInputSubject
    }
    
    fileprivate func generateNewString(from lastString: String?, range: NSRange, addedString: String) -> String? {
        if let text = lastString, let newRange = text.range(from: range)  {
            return text.replacingCharacters(in: newRange, with: addedString)
        }
        return nil
    }
}
