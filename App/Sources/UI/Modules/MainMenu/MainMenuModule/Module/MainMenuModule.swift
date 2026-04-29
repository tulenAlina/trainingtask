import UIKit

protocol MainMenuModuleInputProtocol {}

final class MainMenuModule: Module {
    private(set) var view: UIViewController
    private(set) var input: MainMenuModuleInputProtocol
    
    private init(view: UIViewController, input: MainMenuModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build() -> MainMenuModule {
        let interactor = MainMenuInteractor()
        let router = MainMenuRouter()
        let presenter = MainMenuPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = MainMenuViewController(presenter: presenter)
        
        router.viewController = viewController
        presenter.view = viewController
        
        let module = MainMenuModule(view: viewController, input: presenter)
        return module
    }
}
