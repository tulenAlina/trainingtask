import UIKit

protocol EditTaskModuleInputProtocol {
    func createTask(project: Project?)
    func updateTask(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?)
}

protocol EditTaskModuleOutputProtocol: AnyObject {
    func didCreateTask(_ task: ProjectTask)
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?)
}

final class EditTaskModule: Module {
    private(set) var view: UIViewController
    private(set) var input: EditTaskModuleInputProtocol

    private init(view: UIViewController, input: EditTaskModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(output: EditTaskModuleOutputProtocol? = nil) -> EditTaskModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = EditTaskInteractor(server: server, settings: settings)
        let router = EditTaskRouter()
        let presenter = EditTaskPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = EditTaskViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        
        let module = EditTaskModule(view: viewController, input: presenter)
        return module
    }
}
