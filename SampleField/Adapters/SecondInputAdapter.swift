//
//  SecondInputAdapter.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import Combine
import Foundation

protocol SecondInputAdapterDelegate {
    
    var shuffleButtonAction: InFailablePassThroughSubject<Void> { get }
    
    var textLabelPublisher: InFailableAnyPublisher<String> { get }
}

class SecondInputAdapter: SecondInputAdapterDelegate {
    
    
    // MARK: - Bindings
    
    lazy var shuffleButtonAction = InFailablePassThroughSubject<Void>()
    
    var textLabelPublisher: InFailableAnyPublisher<String> {
        $textLabelSubject
            .subject
            .eraseToAnyPublisher()
    }
    
    @CurrentValuePublished fileprivate var textLabelSubject: String = ""
    
    @CurrentValuePublished fileprivate var popUpButtonVisibilityState: Bool = false
    
    @CurrentValuePublished fileprivate var textInputModel: FirstInputHolderModel = FirstInputHolderModel(input: "")
    
    fileprivate var cancelables = Set<AnyCancellable>()
    
    // MARK: - LifeCycle
    
    fileprivate let inputCachingServicePort: InputCachingServicePort
    
    fileprivate let inputValidationServicePort: InputValidationServicePort
    
    init(inputCachingService: InputCachingServicePort, inputValidationServicePort: InputValidationServicePort) {
        self.inputCachingServicePort = inputCachingService
        self.inputValidationServicePort = inputValidationServicePort
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
            .map(\.input)
            .assign(to: $textLabelSubject)
            .store(in: &cancelables)

    }
    
    fileprivate func startObservingDatabase() {
        
//        inputCachingServicePort
//            .observeInputOnDB()
//            .replaceAnyInconsistency(with: .init(input: ""))
//            .assign(to: $textInputModel)
//            .store(in: &cancelables)
        
        // handle update text on db when it reaches the required length
        shuffleButtonAction
            .combineLatest($textInputModel.subject, { $1 })
            .map { model in
                return model.clone(by: \.input, to: self.inputValidationServicePort.shuffle(input: model.input))
            }
            .flatMap { model in
                return self.inputCachingServicePort
                    .handleInsertOrUpdateInputCaching(input: model)
                    .replaceAnyInconsistency(with: .init(input: ""))
                    .eraseToAnyPublisher()
            }
            .map(\.input)
            .assign(to: $textLabelSubject)
            .store(in: &cancelables)

    }
}
