//
//  FirstInputServicePort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import Combine

protocol FirstInputServicePort {
    
    func handleInputCaching(input: FirstInputHolderModel) -> AnyPublisher<FirstInputHolderModel,FieldError>
    
    func fetchInitialValue() -> AnyPublisher<FirstInputHolderModel,FieldError>
    
    func observeInputOnDB() -> AnyPublisher<FirstInputHolderModel, FieldError>
    
    func checkForInputValidation(from string: String) -> Bool
    
    func isFieldNotEmpty(input: String) -> Bool
}
