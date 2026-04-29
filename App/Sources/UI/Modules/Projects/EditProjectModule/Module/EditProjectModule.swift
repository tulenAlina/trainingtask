import UIKit

protocol EditProjectModuleInputProtocol {
    func createProject()
    func updateProject(project: Project)
}

protocol EditProjectModuleOutputProtocol: AnyObject {
    func didCreateProject(_ project: Project)
    func didUpdateProject(_ project: Project)
}

final class EditProjectModule: Module {
    private(set) var view: UIViewController
    private(set) var input: EditProjectModuleInputProtocol
    
    private init(view: UIViewController, input: EditProjectModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(output: EditProjectModuleOutputProtocol? = nil) -> EditProjectModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = EditProjectInteractor(server: server, settings: settings)
        let router = EditProjectRouter()
        let presenter = EditProjectPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = EditProjectViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        
        let module = EditProjectModule(view: viewController, input: presenter)
        return module
    }
}
