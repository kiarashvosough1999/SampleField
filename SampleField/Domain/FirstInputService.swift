//
//  FirstInputService.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine

final class FirstInputServiceImpl: InputCachingServicePort {
    
    fileprivate let storagePort: PersistenceStoragePort
    
    fileprivate var calcelables: Set<AnyCancellable>
    
    init(storagePort: PersistenceStoragePort) {
        self.storagePort = storagePort
        self.calcelables = Set<AnyCancellable>()
    }
    
    func fetchInitialValue() -> AnyPublisher<FirstInputHolderModel,FieldError> {
        storagePort
            .fetchOne(type: FirstInputHolderModel.self, on: .main)
            .eraseToAnyPublisher()
    }
    
    func observeInputOnDB() -> AnyPublisher<FirstInputHolderModel, FieldError> {
        return storagePort
            .publisher(FirstInputHolderModel.self, changeTypes: [.deleted, .inserted ,.updated])
            .compactMap { $0.combined(sortedBy: \.dateAdded).first }
            .eraseToAnyPublisher()
    }
    
    func handleInsertOrUpdateInputCaching(input: FirstInputHolderModel) -> AnyPublisher<FirstInputHolderModel,FieldError> {
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
    
    func handleDeleteInputCaching(input: FirstInputHolderModel) -> AnyPublisher<FirstInputHolderModel,FieldError> {
        if input.input.isEmpty && input.identifier.isEmpty.not {
            return storagePort
                .deleteOne(input, on: .main)
        }
        return Empty<FirstInputHolderModel,FieldError>().eraseToAnyPublisher()
    }
}
