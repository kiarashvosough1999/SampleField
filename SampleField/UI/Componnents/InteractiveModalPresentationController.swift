//
//  InteractiveModalPresentationController.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import UIKit

final class InteractiveModalPresentationController: UIPresentationController {
    
    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }
        
        let view = UIView(frame: container.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.didPan(pan:)))
        )
        
        return view
    }()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    @objc private func didPan(pan: UIPanGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        
        return CGRect(x: container.bounds.width*1/10,
                      y: container.bounds.height*1/10,
                      width: container.bounds.width - container.bounds.width*1/10*2,
                      height: container.bounds.height - container.bounds.height*1/5)
    }
    
    override func presentationTransitionWillBegin() {
        guard let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator else { return }
        
        dimmingView.alpha = 0
        container.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let stronSelf = self else { return }
            stronSelf.dimmingView.alpha = 1
            }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let stronSelf = self else { return }
            stronSelf.dimmingView.alpha = 0
            }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
}
