//
//  FirstInputHolderModel.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

struct FirstInputHolderModel: NSMangedObjectConvertible {
    
    typealias NSManagedObjectType = TextInputHolder
    
    var identifier: String = ""
    var dateAdded: Date = Date()
    var id: Int64 { Int64(identifier.hashValue) }
    var input: String
}
