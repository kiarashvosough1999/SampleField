//
//  FirstInputViewControllerTest.swift
//  SampleFieldTests
//
//  Created by Kiarash Vosough on 2/11/22.
//

import XCTest
import Combine
@testable import SampleField

class FirstInputViewControllerTest: XCTestCase {

    var viewController: FirstInputViewController!
    var adapter: FirstInputAdapterMock!
    var cancelables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancelables = Set<AnyCancellable>()
        adapter = FirstInputAdapterMock()
        viewController = FirstInputViewController(inputAdapter: adapter)
        viewController.setupBindings()
    }

    override func tearDownWithError() throws {
        viewController = nil
    }

    func testTextFieldDelegateChnages() throws {
        
        let textChangedExpectation = XCTestExpectation()
        textChangedExpectation.expectedFulfillmentCount = 1
        
        adapter.textInputChangeSubject.sink { value in
            textChangedExpectation.fulfill()
        }.store(in: &cancelables)
        
        XCTAssertTrue(viewController.textField(viewController.inputTextfield,
                                               shouldChangeCharactersIn: NSRange(location: 0, length: 2),
                                               replacementString: "T")
        )
        
        wait(for: [textChangedExpectation], timeout: 2)
        
    }
    
    func testObservingText() throws {
        
        let textChangedExpectation = XCTestExpectation()
        textChangedExpectation.expectedFulfillmentCount = 1
        
        adapter.textSubject.sink { str in
            textChangedExpectation.fulfill()
        }.store(in: &cancelables)
        
        adapter.textSubject.send("hiiiii")
        
        XCTAssertEqual(self.viewController.inputTextfield.text, "hiiiii")
        
        wait(for: [textChangedExpectation], timeout: 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
