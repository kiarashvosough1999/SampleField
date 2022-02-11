//
//  ActionPublished.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/11/22.
//

import UIKit
import Combine

final class ActionPublished: UIAction {
    
    convenience init(actionSubject: InFailablePassThroughSubject<Void>?) {
        self.init { [weak actionSubject] _ in
            actionSubject?.send(())
        }
    }
    
    convenience init<T>(actionSubject: InFailablePassThroughSubject<T>?, signalValue: T) {
        self.init { [weak actionSubject, signalValue] _ in
            actionSubject?.send(signalValue)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
