import UIKit

protocol EditTaskModuleInputProtocol: AnyObject {
    func configureForCreate(project: Project?)
    func configureForUpdate(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?)
}

protocol EditTaskModuleOutputProtocol: AnyObject {
    func didCreateTask(_ task: ProjectTask)
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?)
}

final class EditTaskBuilder {
    static func build(moduleOutput: EditTaskModuleOutputProtocol? = nil) -> EditTaskModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        guard let settings else {
            exit(0)
        }
        
        let interactor = EditTaskInteractor(server: server, settings: settings)
        let router = EditTaskRouter(server: server, settings: settings)
        let presenter = EditTaskPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = EditTaskViewController(presenter: presenter)
        
        presenter.moduleOutput = moduleOutput
        router.viewController = viewController
        presenter.view = viewController
        interactor.output = presenter
        
        return EditTaskModule(
            view: viewController,
            input: presenter,
            output: moduleOutput
        )
    }
}
