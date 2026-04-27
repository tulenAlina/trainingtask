import UIKit

protocol ProjectSelectionOutputProtocol: AnyObject {
    func didSelectProject(_ project: Project)
}

protocol ProjectsModuleInputProtocol {}

final class ProjectsModule: Module {
    private(set) var view: UIViewController
    private(set) var input: ProjectsModuleInputProtocol

    private init(view: UIViewController, input: ProjectsModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(selectionOutput: ProjectSelectionOutputProtocol? = nil) -> ProjectsModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = ProjectsInteractor(server: server, settings: settings)
        let router = ProjectsRouter()
        let presenter = ProjectsPresenter(
            interactor: interactor,
            router: router,
            selectionOutput: selectionOutput
        )
        let viewController = ProjectsViewController(presenter: presenter)
        
        router.viewController = viewController
        presenter.view = viewController
        
        let module = ProjectsModule(view: viewController, input: presenter)
        return module
    }
}
