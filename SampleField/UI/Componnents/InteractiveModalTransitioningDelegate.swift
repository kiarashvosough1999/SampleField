//
//  InteractiveModalTransitioningDelegate.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import UIKit

final class InteractiveModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    override init() {
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return InteractiveModalPresentationController(presentedViewController: presented,
                                                      presenting: presenting)
    }
    
}
