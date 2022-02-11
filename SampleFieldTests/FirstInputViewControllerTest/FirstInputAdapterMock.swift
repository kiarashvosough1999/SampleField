//
//  FirstInputAdapterMock.swift
//  SampleFieldTests
//
//  Created by Kiarash Vosough on 2/11/22.
//

import XCTest
import Combine
@testable import SampleField

final class FirstInputAdapterMock: FirstInputAdapterDelegate {
    
    let textInputChangeSubject = PassthroughSubject<(String?, NSRange, String), Never>()
    
    let popUpButtonVisibilityStateSubject = PassthroughSubject<Bool, Never>()
    
    let textSubject = PassthroughSubject<String, Never>()
    
    var textFieldReplacementStringDelegatePublisher: PassthroughSubject<(String?, NSRange, String), Never> {
        textInputChangeSubject
    }
    
    var popUpButtonVisibilityStatePublisher: AnyPublisher<Bool, Never> {
        popUpButtonVisibilityStateSubject.eraseToAnyPublisher()
    }
    
    var textFieldTextPublisher: AnyPublisher<String, Never> {
        textSubject.eraseToAnyPublisher()
    }
}
