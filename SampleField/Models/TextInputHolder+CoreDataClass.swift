//
//  TextInputHolder+CoreDataClass.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//
//

import Foundation
import CoreData

@objc(TextInputHolder)
public class TextInputHolder: NSManagedObject, ObjectConvertible {
    
    func from<T>(object: T) -> Bool where T : NSMangedObjectConvertible {
        
        if let object = object as? FirstInputHolderModel {
            self.input = object.input
            self.id = Int64(objectID.hashValue)
            self.dateAdded = object.dateAdded
            return true
        }
        
        return false
    }
    
    func toObject<T>() throws -> T? where T : NSMangedObjectConvertible {
        guard let dateAdded = dateAdded,
              let input = input else {
                  throw FieldError.dbError(reason: .ValuesFoundNil(propertyNames: [
                    #keyPath(dateAdded),
                    #keyPath(input)
                  ]))
              }
        
        if T.self == FirstInputHolderModel.self {
            return FirstInputHolderModel(identifier: identifier,
                                         dateAdded: dateAdded,
                                         id: Int64(identifier.hashValue),
                                         input: input) as? T
        }
        
        return nil
    }
}
