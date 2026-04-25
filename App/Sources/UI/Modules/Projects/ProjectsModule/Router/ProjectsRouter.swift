import UIKit

protocol ProjectsRouterInputProtocol {
    func openDetailScreen(for project: Project, moduleOutput: ProjectDetailModuleOutputProtocol)
    func openAddProjectScreen(moduleOutput: EditProjectModuleOutputProtocol)
}

final class ProjectsRouter: ProjectsRouterInputProtocol {
    weak var viewController: UIViewController?

    func openDetailScreen(for project: Project, moduleOutput: ProjectDetailModuleOutputProtocol) {
        
        let detailModule = ProjectDetailModule.build(project: project, moduleOutput: moduleOutput)
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func openAddProjectScreen(moduleOutput: EditProjectModuleOutputProtocol) {
        let editModuleViewController = EditProjectModule.build(moduleOutput: moduleOutput)
        editModuleViewController.input.createProject()
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
}
