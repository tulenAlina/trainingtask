import UIKit

protocol TaskEditModuleInputProtocol {
    func createTask(project: Project?)
    func updateTask(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?)
}

protocol TaskEditModuleOutputProtocol: AnyObject {
    func didCreateTask(_ task: ProjectTask)
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?)
}

final class TaskEditModule: Module {
    private(set) var view: UIViewController
    private(set) var input: TaskEditModuleInputProtocol
    
    private init(view: UIViewController, input: TaskEditModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(output: TaskEditModuleOutputProtocol? = nil) -> TaskEditModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = TaskEditInteractor(server: server, settings: settings)
        let router = TaskEditRouter()
        let presenter = TaskEditPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = TaskEditViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        interactor.output = presenter
        
        let module = TaskEditModule(view: viewController, input: presenter)
        return module
    }
}
