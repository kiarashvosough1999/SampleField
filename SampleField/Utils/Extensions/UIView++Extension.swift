//
//  UIView++Extension.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/10/22.
//

import UIKit

extension UIView {
    
    func addSubviews(views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
}
