//
//  main.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import UIKit

class Application: UIApplication, UIApplicationDelegate {}

/// This function avoids calls for AppDelegate in UnitTest.
private func delegateClassName() -> String? {
    return NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : nil
}

let argc = CommandLine.argc
let argv = CommandLine.unsafeArgv
  _ = UIApplicationMain(argc, argv, NSStringFromClass(Application.self), delegateClassName())
