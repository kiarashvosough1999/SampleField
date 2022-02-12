//
//  InputValidationServicePort.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import Foundation

protocol InputValidationServicePort {
    
    func checkForInputValidation(from string: String) -> Bool
    
    func isFieldNotEmpty(input: String) -> Bool
    
    func shuffle(input: String) -> String
    
    func isInputLengthEnough(input: String) -> Bool
    
    func isInputLengthZero(input: String) -> Bool
}
