import Foundation

final class ProjectDetailPresenter: ProjectDetailModuleInputProtocol {
    weak var view: ProjectDetailViewInputProtocol?
    weak var output: ProjectDetailModuleOutputProtocol?
    private let interactor: ProjectDetailInteractorInputProtocol
    private var router: ProjectDetailRouterInputProtocol

    private var project: Project
    
    init(interactor: ProjectDetailInteractorInputProtocol, router: ProjectDetailRouterInputProtocol, project: Project) {
        self.interactor = interactor
        self.router = router
        self.project = project
    }
}

// MARK: - EditProjectModuleOutputProtocol
extension ProjectDetailPresenter: EditProjectModuleOutputProtocol {
    func didUpdateProject(_ project: Project) {
        self.project = project
        
        view?.configureLabels(
            name: project.projectName,
            description: project.description
        )
        output?.didUpdateProject(project)
    }
    
    func didCreateProject(_ project: Project) {}
}

// MARK: - ProjectDetailViewOutputProtocol
extension ProjectDetailPresenter: ProjectDetailViewOutputProtocol {
    func viewDidLoad() {
        view?.configureLabels(
            name: project.projectName,
            description: project.description
        )
    }
    
    func didTapOpenTasksButton() {
        router.pushTasksScreen(project: project)
    }
    
    func didTapChangeButton() {
        router.pushEditScreen(project: project, output: self)
    }
    
    func didTapDeleteButton() {
        output?.didDeleteProject(project.id)
        router.close()
    }
}
