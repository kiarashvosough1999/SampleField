//
//  AppStyle++TextField.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/10/22.
//

import UIKit

class TextField: UITextField {}

extension TextField {
    
    var orEmptyText: String {
        get {
            text.or("")
        }
        set {
            text = newValue
        }
    }
}

extension AppStyle {
    
    struct TextFields {
        
        func simpleField() -> UIViewStyle<TextField> {
            UIViewStyle { view in
                view.borderStyle = .roundedRect
                view.translatesAutoresizingMaskIntoConstraints = false
                view.placeholder = "Enter Text"
                view.textAlignment = .center
            }
        }
        
    }
    
}
