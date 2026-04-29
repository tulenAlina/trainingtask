import UIKit

protocol ProjectEditModuleInputProtocol {
    func createProject()
    func updateProject(project: Project)
}

protocol ProjectEditModuleOutputProtocol: AnyObject {
    func didCreateProject(_ project: Project)
    func didUpdateProject(_ project: Project)
}

final class ProjectEditModule: Module {
    private(set) var view: UIViewController
    private(set) var input: ProjectEditModuleInputProtocol
    
    private init(view: UIViewController, input: ProjectEditModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(output: ProjectEditModuleOutputProtocol? = nil) -> ProjectEditModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = ProjectEditInteractor(server: server, settings: settings)
        let router = ProjectEditRouter()
        let presenter = ProjectEditPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = ProjectEditViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        
        let module = ProjectEditModule(view: viewController, input: presenter)
        return module
    }
}
