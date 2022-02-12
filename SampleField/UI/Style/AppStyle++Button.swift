//
//  AppStyle++Button.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/10/22.
//

import UIKit

class Button: UIButton {}

extension AppStyle {
    
    struct Buttons {
        
        func openPopUpButton() -> UIViewStyle<Button> {
            UIViewStyle { view in
                view.isEnabled = false
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setTitle("Open PopUp", for: [.normal])
                view.backgroundColor = .lightGray
                view.setTitleColor(.yellow, for: [.normal])
            }
        }
        
        func closePopUpButton() -> UIViewStyle<Button> {
            UIViewStyle { view in
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setTitle("Close PopUp", for: [.normal])
                view.backgroundColor = .lightGray
                view.setTitleColor(.yellow, for: [.normal])
            }
        }
        
        func shuffleTextButton() -> UIViewStyle<Button> {
            UIViewStyle { view in
                view.translatesAutoresizingMaskIntoConstraints = false
                view.setTitle("Shuffle", for: [.normal])
                view.backgroundColor = .lightGray
                view.setTitleColor(.yellow, for: [.normal])
            }
        }
    }
}
