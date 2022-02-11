//
//  FirstInputHolderModel.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import Foundation

struct FirstInputHolderModel: NSMangedObjectConvertible, Clonable {
    
    typealias NSManagedObjectType = TextInputHolder
    
    var identifier: String = ""
    var dateAdded: Date = Date()
    var id: Int64
    var input: String
    
    init(identifier: String = "", dateAdded: Date = Date(), id: Int64 = 0, input: String) {
        self.identifier = identifier
        self.dateAdded = dateAdded
        self.id = id == 0 ? Int64(identifier.hashValue) : id
        self.input = input
    }
}
