//
//  Locator.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

/// Recursive resolving must use locks, As it takes time to implement I ignored it for now
struct RegisteryOptions<Service> {
    
    let container: ServiceContainer
    
    @discardableResult
    public func implements<Protocol>(_ type: Protocol.Type) -> Self {
        container.addService { container -> Protocol in
            let res: Service = container.getService()!
            return res as! Protocol
        }
        return self
    }
}

protocol ServiceLocator {
    
    func getService<T>() -> T?
    
    @discardableResult
    func addService<T>(recipe: @escaping (ServiceLocator) -> T) -> RegisteryOptions<T>
    
    @discardableResult
    func addService<T>(instance: T) -> RegisteryOptions<T>
}

final class ServiceContainer: ServiceLocator {
    
    static let main: ServiceContainer = ServiceContainer()
    
    static func initial() { _ = ServiceContainer.main }
    
    /// Service registry
    private lazy var reg: Dictionary<String, RegistryRec> = [:]
    
    private func typeName(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }
    
    @discardableResult
    func addService<T>(recipe: @escaping (ServiceLocator) -> T) -> RegisteryOptions<T> {
        let key = typeName(some: T.self)
        reg[key] = .Recipe(recipe)
        return .init(container: self)
    }
    
    @discardableResult
    func addService<T>(instance: T) -> RegisteryOptions<T> {
        let key = typeName(some: T.self)
        reg[key] = .Instance(instance)
        return .init(container: self)
    }
    
    func getService<T>() -> T? {
        let key = typeName(some: T.self)
        var instance: T? = nil
        if let registryRec = reg[key] {
            instance = registryRec.unwrap(with: self) as? T
            switch registryRec {
            case .Recipe:
                if let instance = instance {
                    addService(instance: instance)
                }
            default:
                break
            }
        }
        return instance
    }
    
}

extension ServiceContainer {
    
    fileprivate enum RegistryRec {
        
        case Instance(Any)
        case Recipe((ServiceLocator) -> Any)
        
        func unwrap(with locator: ServiceLocator) -> Any {
            switch self {
            case .Instance(let instance):
                return instance
            case .Recipe(let recipe):
                return recipe(locator)
            }
        }
    }
}

extension ServiceContainer: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
