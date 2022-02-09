//
//  Delegated.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

@propertyWrapper
final class MainQueue {
    
    var wrappedValue: (() -> Void)?
    
    var projectedValue: MainQueue { self }
    
    func execute() {
        DispatchQueue.main.async { [weak self] in
            self?.wrappedValue?()
        }
    }
    
    public func byWrapping<Wrraped>(_ wrapp: Wrraped,_ binding: @escaping ((Wrraped) -> Void)) where Wrraped: AnyObject {
        wrappedValue = { [weak wrapp] in
            guard let wrapp = wrapp else { return }
            binding(wrapp)
        }
    }
    
    public func byWrapping<Wrraped1,Wrraped2>(_ wrapp1: Wrraped1,_ wrapp2: Wrraped2 ,_ binding: @escaping ((Wrraped1, Wrraped2) -> Void)) where Wrraped1: AnyObject, Wrraped2: AnyObject {
        wrappedValue = { [weak wrapp1, weak wrapp2] in
            guard let wrapp1 = wrapp1, let wrapp2 = wrapp2 else { return }
            binding(wrapp1, wrapp2)
        }
    }
    
    public func byWrapping<Wrraped1,Wrraped2,Wrraped3>(_ wrapp1: Wrraped1,_ wrapp2: Wrraped2, _ wrapp3: Wrraped3,_ binding: @escaping ((Wrraped1, Wrraped2, Wrraped3) -> Void)) where Wrraped1: AnyObject, Wrraped2: AnyObject, Wrraped3: AnyObject {
        wrappedValue = { [weak wrapp1, weak wrapp2, weak wrapp3] in
            guard let wrapp1 = wrapp1, let wrapp2 = wrapp2, let wrapp3 = wrapp3 else { return }
            binding(wrapp1, wrapp2, wrapp3)
        }
    }
}

@propertyWrapper
final class MainQueue01<T> {
    
    var wrappedValue: (() -> T?)?
    
    var projectedValue: MainQueue01 { self }
    
    func execute(_ completed: @escaping (T?) -> Void) {
        DispatchQueue.main.async { [weak self] in
            completed(self?.wrappedValue?())
        }
    }
    
    public func byWrapping<Wrraped>(_ wrapp: Wrraped,_ binding: @escaping ((Wrraped) -> T?)) where Wrraped: AnyObject {
        wrappedValue = { [weak wrapp] in
            guard let wrapp = wrapp else { return nil }
            return binding(wrapp)
        }
    }
}

@propertyWrapper
final class MainQueue1<T> {
    
    var wrappedValue: ((T) -> Void)?
    
    var projectedValue: MainQueue1 { self }
    
    func execute(_ arg: T) {
        DispatchQueue.main.async { [weak self] in
            self?.wrappedValue?(arg)
        }
    }
    
    public func byWrapping<Wrraped>(_ wrapp: Wrraped,_ binding: @escaping ((Wrraped, T) -> Void)) where Wrraped: AnyObject {
        wrappedValue = { [weak wrapp] arg in
            guard let wrapp = wrapp else { return }
            binding(wrapp, arg)
        }
    }
}

@propertyWrapper
final class MainQueue2<T,H> {
    
    var wrappedValue: ((T,H) -> Void)?
    
    var projectedValue: MainQueue2 { self }
    
    func execute(_ arg1: T,_ arg2: H) {
        DispatchQueue.main.async { [weak self] in
            self?.wrappedValue?(arg1, arg2)
        }
    }
    
    public func byWrapping<Wrraped>(_ wrapp: Wrraped,_ binding: @escaping ((Wrraped, T,H) -> Void)) where Wrraped: AnyObject {
        wrappedValue = { [weak wrapp] arg1, arg2 in
            guard let wrapp = wrapp else { return }
            binding(wrapp, arg1, arg2)
        }
    }
}

@propertyWrapper
final class MainQueue3<T,H,K> {
    
    var wrappedValue: ((T,H,K) -> Void)?
    
    var projectedValue: MainQueue3 { self }
    
    func execute(_ arg1: T,_ arg2: H, _ arg3: K) {
        DispatchQueue.main.async { [weak self] in
            self?.wrappedValue?(arg1, arg2, arg3)
        }
    }
    
    public func byWrapping<Wrraped>(_ wrapp: Wrraped,_ binding: @escaping ((Wrraped, T,H,K) -> Void)) where Wrraped: AnyObject {
        wrappedValue = { [weak wrapp] arg1, arg2, arg3 in
            guard let wrapp = wrapp else { return }
            binding(wrapp, arg1, arg2, arg3)
        }
    }
}

@propertyWrapper
final class MainQueue4<T,H,K,F> {
    
    var wrappedValue: ((T,H,K,F) -> Void)?
    
    var projectedValue: MainQueue4 { self }
    
    func execute(_ arg1: T,_ arg2: H, _ arg3: K,  _ arg4: F) {
        DispatchQueue.main.async { [weak self] in
            self?.wrappedValue?(arg1, arg2, arg3, arg4)
        }
    }
    
    public func byWrapping<Wrraped>(_ wrapp: Wrraped,_ binding: @escaping ((Wrraped, T,H,K,F) -> Void)) where Wrraped: AnyObject {
        wrappedValue = { [weak wrapp] arg1, arg2, arg3, arg4 in
            guard let wrapp = wrapp else { return }
            binding(wrapp, arg1, arg2, arg3, arg4)
        }
    }
}

@propertyWrapper
final class MainQueue5<T,H,K,F,U> {
    
    var wrappedValue: ((T,H,K,F,U) -> Void)?
    
    var projectedValue: MainQueue5 { self }
    
    func execute(_ arg1: T,_ arg2: H, _ arg3: K,  _ arg4: F, _ arg5: U) {
        DispatchQueue.main.async { [weak self] in
            self?.wrappedValue?(arg1, arg2, arg3, arg4, arg5)
        }
    }
    
    public func byWrapping<Wrraped>(_ wrapp: Wrraped,_ binding: @escaping ((Wrraped, T,H,K,F,U) -> Void)) where Wrraped: AnyObject {
        wrappedValue = { [weak wrapp] arg1, arg2, arg3, arg4, arg5 in
            guard let wrapp = wrapp else { return }
            binding(wrapp, arg1, arg2, arg3, arg4, arg5)
        }
    }
}
