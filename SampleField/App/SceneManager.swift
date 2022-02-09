//
//  SceneManager.swift
//  SampleField
//
//  Created by Kiarash Vosough on 2/9/22.
//

import UIKit

final class SceneManager {

    var activityIdentifier: ActivityIdentifier? {
        options
            .userActivities
            .compactMap { ActivityIdentifier(rawValue: $0.activityType) }
            .first
    }

    private let options: UIScene.ConnectionOptions

    init(with options: UIScene.ConnectionOptions) {
        self.options = options
    }

    func generateUISceneConfiguration() -> UISceneConfiguration {
        let identifier = activityIdentifier ?? .mainApp
        switch identifier {
        case .mainApp:
            return generateMainAppConfig(with: identifier.rawValue)
        }
    }

    fileprivate func generateMainAppConfig(with identifier: String) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: identifier + " Configuration",
                                          sessionRole: .windowApplication)
        config.delegateClass = MainAppSceneDelegate.self
        return config
    }
}

extension SceneManager {

    enum ActivityIdentifier: String {
        case mainApp
    }

}
