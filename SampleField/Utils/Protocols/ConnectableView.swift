//
//  ConnectableView.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/10/22.
//

import UIKit

protocol ConnectableView: UIResponder {
    
    func setupBindings()
    
    func addViews()
    
    @ConstraintBuilder
    func setupConstraints() -> [NSLayoutConstraint]
    
    func setupView()
}

extension ConnectableView where Self: UIViewController {
    
    func activateConstraints() {
        NSLayoutConstraint.activate(setupConstraints())
    }
}

extension ConnectableView {
    
    func setupBindings() {}
    
    func addViews() {}
    
    func setupView() {}
}


@resultBuilder
struct ConstraintBuilder {
    
    static func buildBlock(_ components: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        components
    }
    
    static func buildOptional(_ component: [NSLayoutConstraint]?) -> [NSLayoutConstraint] {
        component.or([])
    }
}
