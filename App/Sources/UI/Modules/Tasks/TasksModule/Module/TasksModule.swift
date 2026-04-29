import UIKit

protocol TasksModuleInputProtocol {}

final class TasksModule: Module {
    private(set) var view: UIViewController
    private(set) var input: TasksModuleInputProtocol
    
    private init(view: UIViewController, input: TasksModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(project: Project? = nil) -> TasksModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = TasksInteractor(server: server, settings: settings)
        let router = TasksRouter()
        let presenter = TasksPresenter(
            interactor: interactor,
            router: router,
            project: project,
        )
        let viewController = TasksViewController(presenter: presenter)
        
        router.viewController = viewController
        presenter.view = viewController
        interactor.output = presenter
        
        let module = TasksModule(view: viewController, input: presenter)
        return module
    }
}
