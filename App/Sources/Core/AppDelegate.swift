//
//  AppDelegate.swift
//  trainingtask
//
//  Created by Яшенок Алина Игоревна on 11.03.26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let server: Server = StubServer()
    private let settings: SettingsManager = SettingsManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let splashViewController = SplashViewController()
        window?.rootViewController = splashViewController
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.showMainMenu()
        }
        return true
    }
    
    private func showMainMenu() {
        let mainMenuViewController = MainMenuViewController(server: server, settings: settings)
        let navigationController = UINavigationController(rootViewController: mainMenuViewController)
        window?.rootViewController = navigationController
    }

}

