//
//  Bool++Extension.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

extension Bool {
    
    var not: Bool { !self }
    
    var isTrue: Bool { self == true }
    
    var isFalse: Bool { self == false }
    
    mutating func toggleTrue() { self = true }
    
    mutating func toggleFalse() { self = false }
}
