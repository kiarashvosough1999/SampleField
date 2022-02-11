//
//  PersistenceStorageTest.swift
//  SampleFieldTests
//
//  Created by Kiarash Vosough on 2/11/22.
//

import XCTest
import Combine
@testable import SampleField

class PersistenceStorageTest: XCTestCase {

    var coreDataPersistenceStorageAdapter: CoreDataPersistenceStorageAdapterMock!
    
    var cancelables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancelables = Set<AnyCancellable>()
        coreDataPersistenceStorageAdapter = CoreDataPersistenceStorageAdapterMock()
    }

    override func tearDownWithError() throws {
        cancelables = nil
        coreDataPersistenceStorageAdapter = nil
    }
    
    func testInsertSyncOnMainContext() throws {
        
        let mockData = FirstInputHolderModel(input: "Test")
        
        let result = coreDataPersistenceStorageAdapter.insertSync(mockData)
        
        XCTAssertNoThrow(try result.get())
        
        XCTAssertTrue(try! result.get().identifier.isEmpty.not)
        
        let uri = URL(string: try! result.get().identifier)
        
        XCTAssertNotNil(uri)
        
        let objectID = coreDataPersistenceStorageAdapter
            .mainContext
            .persistentStoreCoordinator?
            .managedObjectID(forURIRepresentation: uri!)
        
        XCTAssertNotNil(objectID)
        
        let model = coreDataPersistenceStorageAdapter.mainContext.object(with: objectID!) as? TextInputHolder
        
        XCTAssertNotNil(model)
        
        XCTAssertEqual(model!.input, try! result.get().input)
    }
    
    func testDeleteSyncOnMainContext() throws {
        
        let mockData = FirstInputHolderModel(input: "Test")
        
        let result = coreDataPersistenceStorageAdapter.insertSync(mockData)
        
        XCTAssertNoThrow(try result.get())
        
        XCTAssertTrue(try! result.get().identifier.isEmpty.not)
        
        // test count
        
        let fetchResult: Result<[FirstInputHolderModel], FieldError> = coreDataPersistenceStorageAdapter.fetchAll()
        
        XCTAssertNoThrow(try fetchResult.get())
        
        XCTAssertEqual(try! fetchResult.get().count, 1)
        
        let sinkDeletedExpectation = XCTestExpectation()
        sinkDeletedExpectation.expectedFulfillmentCount = 1

        coreDataPersistenceStorageAdapter
            .deleteOne(try! fetchResult.get().first!, on: .main)
            .sink { _ in
            } receiveValue: { deletedModel in
                sinkDeletedExpectation.fulfill()
                
                let fetchResultAfterDelete: Result<[FirstInputHolderModel], FieldError> = self.coreDataPersistenceStorageAdapter.fetchAll()

                XCTAssertEqual(try! fetchResultAfterDelete.get().count, 0)
            }.store(in: &cancelables)


        wait(for: [sinkDeletedExpectation], timeout: 2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
