//
//  Clonable.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/10/22.
//

import Foundation

protocol Clonable {
    
    func clone() -> Self
    
    func clone<T>(by changing: WritableKeyPath<Self,T>, to value: T) -> Self
}

extension Clonable {
    
    func clone() -> Self {
        let new = self
        return new
    }
    
    func clone<T>(by changing: WritableKeyPath<Self,T>, to value: T) -> Self {
        var new = self
        new[keyPath: changing] = value
        return new
    }
}
