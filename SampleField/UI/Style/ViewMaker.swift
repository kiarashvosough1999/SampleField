//
//  ViewMaker.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/10/22.
//

import UIKit

final class ViewMaker {
    
    private var _view: UIView!
    
    public var button: ViewMaker {
        _view = Button(type: .system)
        return self
    }
    public var textField: ViewMaker {
        _view = TextField(frame: .zero)
        return self
    }
    
    public var view: ViewMaker {
        _view = UIView(frame: .zero)
        return self
    }
    
    // style adding
    
    @discardableResult func getView() -> UIView {
        return _view
    }
    
    @discardableResult func with(style: UIViewStyle<Button>) -> Button {
        let view = _view as! Button
        style.apply(to: (view))
        return view
    }
    
    @discardableResult func with(style: UIViewStyle<TextField>) -> TextField {
        let view = _view as! TextField
        style.apply(to: (view))
        return view
    }
    
    @discardableResult func with(style: UIViewStyle<UIView>) -> UIView {
        let view = _view!
        style.apply(to: (view))
        return view
    }
}
