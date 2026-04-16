import UIKit

final class EditTaskBuilder {   
    static func build(task: ProjectTask? = nil, project: Project?, isOpenedFromProject: Bool, employee: Employee? = nil, server: Server, settings: SettingsManager, action: EditTaskAction) -> UIViewController {
        let interactor = EditTaskInteractor(server: server, settings: settings)
        let router = EditTaskRouter(server: server, settings: settings)
        let presenter = EditTaskPresenter(interactor: interactor, router: router, task: task, project: project, isOpenedFromProject: isOpenedFromProject, employee: employee, action: action)
        let viewController = EditTaskViewController(presenter: presenter)
        
        router.viewController = viewController
        presenter.view = viewController
        
        return viewController
    }
}
