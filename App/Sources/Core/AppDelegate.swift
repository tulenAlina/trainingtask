import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let server: Server = StubServer()
    private let settings: SettingsManager = SettingsManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Thread.sleep(forTimeInterval: 5.0)
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainMenuViewController = MainMenuViewController(server: server, settings: settings)
        let navigationController = UINavigationController(rootViewController: mainMenuViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
}

