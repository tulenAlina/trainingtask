import UIKit

protocol SettingsModuleInputProtocol {}

protocol SettingsModuleOutputProtocol: AnyObject {}

final class SettingsModule: Module {
    private(set) var view: UIViewController
    private(set) var input: SettingsModuleInputProtocol
    
    private init(view: UIViewController, input: SettingsModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(output: SettingsModuleOutputProtocol? = nil) -> SettingsModule {
        let settings = AppDelegate.settings
        
        let interactor = SettingsInteractor(settings: settings)
        let router = SettingsRouter()
        let presenter = SettingsPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = SettingsViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        interactor.output = presenter
        
        let module = SettingsModule(view: viewController, input: presenter)
        return module
    }
}
