import UIKit

protocol ProjectsRouterInputProtocol {
    func pushDetailScreen(for project: Project, output: ProjectDetailModuleOutputProtocol)
    func pushAddProjectScreen(output: EditProjectModuleOutputProtocol)
    func close()
}

final class ProjectsRouter: ProjectsRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushDetailScreen(for project: Project, output: ProjectDetailModuleOutputProtocol) {
        
        let detailModule = ProjectDetailModule.build(project: project, output: output)
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func pushAddProjectScreen(output: EditProjectModuleOutputProtocol) {
        let editModuleViewController = EditProjectModule.build(output: output)
        editModuleViewController.input.createProject()
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
