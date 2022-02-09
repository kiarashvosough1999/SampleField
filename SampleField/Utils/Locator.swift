//
//  Locator.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

protocol ServiceLocator {
    func getService<T>() -> T?
}

final class ServiceContainer: ServiceLocator {

    /// Service registry
    private lazy var reg: Dictionary<String, RegistryRec> = [:]

    private func typeName(some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }

    func addService<T>(recipe: @escaping () -> T) {
        let key = typeName(some: T.self)
        reg[key] = .Recipe(recipe)
    }

    func addService<T>(instance: T) {
        let key = typeName(some: T.self)
        reg[key] = .Instance(instance)
    }

    func getService<T>() -> T? {
        let key = typeName(some: T.self)
        var instance: T? = nil
        if let registryRec = reg[key] {
            instance = registryRec.unwrap() as? T
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
        case Recipe(() -> Any)

        func unwrap() -> Any {
            switch self {
                case .Instance(let instance):
                    return instance
                case .Recipe(let recipe):
                    return recipe()
            }
        }
    }
}
