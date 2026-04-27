import UIKit

protocol ProjectsRouterInputProtocol {
    func pushDetailScreen(for project: Project, moduleOutput: ProjectDetailModuleOutputProtocol)
    func pushAddProjectScreen(moduleOutput: EditProjectModuleOutputProtocol)
    func close()
}

final class ProjectsRouter: ProjectsRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushDetailScreen(for project: Project, moduleOutput: ProjectDetailModuleOutputProtocol) {
        
        let detailModule = ProjectDetailModule.build(project: project, moduleOutput: moduleOutput)
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func pushAddProjectScreen(moduleOutput: EditProjectModuleOutputProtocol) {
        let editModuleViewController = EditProjectModule.build(moduleOutput: moduleOutput)
        editModuleViewController.input.createProject()
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
