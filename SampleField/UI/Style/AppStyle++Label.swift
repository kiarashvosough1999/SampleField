//
//  AppStyle++Label.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/12/22.
//

import UIKit

class Label: UILabel {}

extension Label {
    
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
    
    struct Labels {
        
        func simpleLabel() -> UIViewStyle<TextField> {
            UIViewStyle { view in
                view.textColor = .black
                view.font = .systemFont(ofSize: 15)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.textAlignment = .center
            }
        }
    }
    
}
