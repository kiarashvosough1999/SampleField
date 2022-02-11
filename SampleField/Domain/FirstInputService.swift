//
//  FirstInputService.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine

final class FirstInputServiceImpl {
    
    fileprivate let storagePort: PersistenceStoragePort
    
    fileprivate var calcelables: Set<AnyCancellable>
    
    init(storagePort: PersistenceStoragePort) {
        self.storagePort = storagePort
        self.calcelables = Set<AnyCancellable>()
    }
}

extension FirstInputServiceImpl: FirstInputServicePort {
    
    func fetchInitialValue() -> AnyPublisher<FirstInputHolderModel,FieldError> {
        storagePort
            .fetchOne(type: FirstInputHolderModel.self, on: .main)
            .eraseToAnyPublisher()
    }
    
    func observeInputOnDB() -> AnyPublisher<FirstInputHolderModel, FieldError> {
        let deletedPublisher = storagePort.publisher(FirstInputHolderModel.self, changeType: .deleted)
        let insertedPublisher = storagePort.publisher(FirstInputHolderModel.self, changeType: .inserted)
        let updatedPublisher = storagePort.publisher(FirstInputHolderModel.self, changeType: .updated)
        return Publishers
            .Merge3(deletedPublisher,insertedPublisher,updatedPublisher)
            .compactMap { $0.resuleValues.first }
            .eraseToAnyPublisher()
    }
    
    func checkForInputValidation(from string: String) -> Bool {
        string.matches(#"^\d\d\d\d-\d\d\d\d\d$"#)
    }
    
    func isFieldNotEmpty(input: String) -> Bool {
        return !input.isEmpty && input.count == 10 ? true : false
    }
    
    func handleInputCaching(input: FirstInputHolderModel) -> AnyPublisher<FirstInputHolderModel,FieldError> {
        if checkForInputValidation(from: input.input) {
            // first time to save -> insert
            if input.identifier.isEmpty {
                return storagePort
                    .insert(input, on: .main)
                    .eraseToAnyPublisher()
            }
            else {
                return storagePort
                    .update(input, on: .main)
                    .eraseToAnyPublisher()
            }
        }
        else if input.input.isEmpty && input.identifier.isEmpty.not {
            return storagePort
                .deleteOne(input, on: .main)
        }
        return Empty<FirstInputHolderModel,FieldError>().eraseToAnyPublisher()
    }
}
