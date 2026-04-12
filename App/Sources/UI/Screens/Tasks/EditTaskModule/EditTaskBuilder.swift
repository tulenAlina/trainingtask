import UIKit

final class EditTaskBuilder {
    static func build(task: ProjectTask? = nil, project: Project? = nil, server: Server, settings: SettingsManager, onCreate: ((ProjectTask) -> Void)?, onUpdate: ((ProjectTask) -> Void)?) -> UIViewController {
        let viewController = EditTaskViewController2()
        let interactor = EditTaskInteractor(server: server, settings: settings)
        let router = EditTaskRouter(server: server, settings: settings)
        let presenter: EditTaskPresenter
        if let onCreate {
            presenter = EditTaskPresenter(view: viewController, interactor: interactor, router: router, task: task, project: project, onCreate: onCreate)
        } else {
            guard let onUpdate else { return UIViewController() }
            presenter = EditTaskPresenter(view: viewController, interactor: interactor, router: router, task: task, project: project, onUpdate: onUpdate)
        }
        
        router.viewController = viewController
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
