//
//  FirstInputServicePort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine

protocol InputCachingServicePort {
    
    func handleInsertOrUpdateInputCaching(input: FirstInputHolderModel) -> AnyPublisher<FirstInputHolderModel,FieldError>
    
    func handleDeleteInputCaching(input: FirstInputHolderModel) -> AnyPublisher<FirstInputHolderModel,FieldError>
    
    func fetchInitialValue() -> AnyPublisher<FirstInputHolderModel,FieldError>
    
    func observeInputOnDB() -> AnyPublisher<FirstInputHolderModel, FieldError>
}
