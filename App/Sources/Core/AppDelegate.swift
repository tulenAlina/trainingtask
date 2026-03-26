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
    private(set) var server: Server = StubServer()
    private(set) var settings: SettingsManager = SettingsManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        self.window = window
        window.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.showMainMenu()
        }
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func showMainMenu() {
        let mainMenuViewController = MainMenuViewController()
        let navigationController = UINavigationController(rootViewController: mainMenuViewController)
        window?.rootViewController = navigationController
    }

}

