//
//  InputValidationService.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import Foundation

class InputValidationService: InputValidationServicePort  {

    func shuffle(input: String) -> String {
        var result = input
            .split(separator: "-")
            .map { String($0) }
            .reduce("") { partialResult, next in
                partialResult + "-" + next.shuffled()
            }
        result.removeFirst()
        result.removeLast()
        return result
    }
    
    func isInputLengthZero(input: String) -> Bool {
        return input.count == 0 ? true : false
    }
    
    func isInputLengthEnough(input: String) -> Bool {
        return input.count == 10 ? true : false
    }
    
    func checkForInputValidation(from string: String) -> Bool {
        string.matches(#"^\d\d\d\d-\d\d\d\d\d$"#)
    }
    
    func isFieldNotEmpty(input: String) -> Bool {
        return !input.isEmpty && input.count == 10 ? true : false
    }
}
