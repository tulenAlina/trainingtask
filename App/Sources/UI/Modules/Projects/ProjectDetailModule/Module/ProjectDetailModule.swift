import UIKit

protocol ProjectDetailModuleInputProtocol {}

protocol ProjectDetailModuleOutputProtocol: AnyObject {
    func didUpdateProject(_ project: Project)
    func didDeleteProject(with projectID: UUID)
}

final class ProjectDetailModule: Module {
    private(set) var view: UIViewController
    private(set) var input: ProjectDetailModuleInputProtocol

    private init(view: UIViewController, input: ProjectDetailModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(project: Project, moduleOutput: ProjectDetailModuleOutputProtocol?) -> ProjectDetailModule {
        let interactor = ProjectDetailInteractor()
        let router = ProjectDetailRouter()
        let presenter = ProjectDetailPresenter(
            interactor: interactor,
            router: router,
            project: project
        )
        let viewController = ProjectDetailViewController(presenter: presenter)
        
        presenter.output = moduleOutput
        router.viewController = viewController
        presenter.view = viewController
        
        let module = ProjectDetailModule(view: viewController, input: presenter)
        return module
    }
}
