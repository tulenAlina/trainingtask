import UIKit

final class EditTaskBuilder {
    static func build(server: Server, settings: SettingsManager) -> UIViewController {
        let viewController = EditTaskViewController2()
        let interactor = EditTaskInteractor(server: server, settings: settings)
        let router = EditTaskRouter(server: server, settings: settings)
        let presenter = EditTaskPresenter(view: viewController,interactor: interactor, router: router)
        
        router.viewController = viewController
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
