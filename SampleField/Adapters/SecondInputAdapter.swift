//
//  SecondInputAdapter.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import Foundation

protocol SecondInputAdapterDelegate {
    
    var shuffleButtonAction: InFailablePassThroughSubject<Void> { get }
}

class SecondInputAdapter: SecondInputAdapterDelegate {
    
    lazy var shuffleButtonAction = InFailablePassThroughSubject<Void>()
    
    
}
