//
//  InputValidationServiceTest.swift
//  SampleFieldTests
//
//  Created by Kiarash Vosough on 2/12/22.
//

import XCTest
@testable import SampleField

class InputValidationServiceTest: XCTestCase {

    var inputValidationService: InputValidationService!
    
    override func setUpWithError() throws {
        inputValidationService = InputValidationService()
    }

    override func tearDownWithError() throws {
        inputValidationService = nil
    }

    func testShuffle() throws {
        
        let testString = "3232-21212"
        
        let result = inputValidationService.shuffle(input: testString)
        
        XCTAssertNotEqual(testString, result)
    }
    
    func testInputValidation() throws {
        
        let testString = "3232-21212"
        
        XCTAssertTrue(inputValidationService.checkForInputValidation(from: testString))
        
        let testStringInvalid = "31232-21212"
        
        XCTAssertFalse(inputValidationService.checkForInputValidation(from: testStringInvalid))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
