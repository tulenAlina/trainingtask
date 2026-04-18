import UIKit

protocol EditTaskModuleInputProtocol {
    func configureForCreate(project: Project?)
    func configureForUpdate(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?)
}

protocol EditTaskModuleOutputProtocol: AnyObject {
    func didCreateTask(_ task: ProjectTask)
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?)
}

protocol Module {
    var view: UIViewController { get }
}

final class EditTaskModule: Module {
    var view: UIViewController
    let input: EditTaskModuleInputProtocol

    init(view: UIViewController, input: EditTaskModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(moduleOutput: EditTaskModuleOutputProtocol? = nil) -> EditTaskModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = EditTaskInteractor(server: server, settings: settings)
        let router = EditTaskRouter()
        let presenter = EditTaskPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = EditTaskViewController(presenter: presenter)
        
        presenter.output = moduleOutput
        router.viewController = viewController
        presenter.view = viewController
        interactor.output = presenter
        
        let module = EditTaskModule(view: viewController, input: presenter)
        
        return module
    }
}
