//
//  Array++Extension.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

extension Array {
    
    func safeIndex(index: Int) -> Array.Element? {
        if count > index && index >= 0 {
            return self[index]
        }
        return nil
    }
    
    subscript(safe: Int) -> Array.Element? {
        get {
            if count > safe && safe >= 0 {
                return self[safe]
            }
            return nil
        }
        set {
            if count > safe && safe >= 0 {
                self[safe] = newValue
            }
        }
    }
}
