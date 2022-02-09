//
//  PersistenceModels++Protocols.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation
import CoreData

protocol ObjectConvertible: NSManagedObject {
    
    /// A String representing a URI that provides an archiveable reference to the object in Core Data.
    var identifier: String { get }
    
    /// Set the managed object's parameters with an object's parameters.
    ///
    /// - Parameter object: An object.
    func from<T>(object: T) -> Bool where T: NSMangedObjectConvertible
    
    /// Create an object, populated with the managed object's properties.
    ///
    /// - Returns: An object.
    func toObject<T>() throws -> T? where T: NSMangedObjectConvertible
}

extension ObjectConvertible {
    
    var identifier: String {
        objectID.uriRepresentation().absoluteString
    }
}

protocol NSMangedObjectConvertible: Hashable {
    
    associatedtype NSManagedObjectType: ObjectConvertible
    
    /// An identifier that is used to fetch the corresponding database object.
    var identifier: String { get }
}
