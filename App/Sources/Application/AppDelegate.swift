import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    static let server: Server = StubServer()
    static let settings: SettingsManager = SettingsManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Thread.sleep(forTimeInterval: 5.0)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if AppDelegate.settings.didFailToLoadConfig {
            showFatalErrorAndExit()
            return false
        }
        
        let mainMenuModule = MainMenuModule.build()
        let navigationController = UINavigationController(rootViewController: mainMenuModule.view)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    private func showFatalErrorAndExit() {
        window?.backgroundColor = .white
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        
        let alert = UIAlertController(title: Localized.alertTitle, message: Localized.configFileUploadError, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Localized.ok, style: .default) { _ in
            exit(0)
        })
        window?.rootViewController?.present(alert, animated: true)
    }
}

