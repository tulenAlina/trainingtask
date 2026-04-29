import UIKit

protocol TaskDetailModuleInputProtocol {}

protocol TaskDetailModuleOutputProtocol: AnyObject {
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?)
    func didDeleteTask(_ taskID: UUID)
}

final class TaskDetailModule: Module {
    private(set) var view: UIViewController
    private(set) var input: TaskDetailModuleInputProtocol
    
    private init(view: UIViewController, input: TaskDetailModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool, output: TaskDetailModuleOutputProtocol?) -> TaskDetailModule {
        let interactor = TaskDetailInteractor()
        let router = TaskDetailRouter()
        let presenter = TaskDetailPresenter(
            interactor: interactor,
            router: router,
            task: task,
            project: project,
            employee: employee,
            isOpenedFromProject: isOpenedFromProject
        )
        let viewController = TaskDetailViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        interactor.output = presenter
        
        let module = TaskDetailModule(view: viewController, input: presenter)
        return module
    }
}
