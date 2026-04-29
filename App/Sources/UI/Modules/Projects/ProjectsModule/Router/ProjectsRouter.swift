import UIKit

protocol ProjectsRouterInputProtocol {
    func pushDetailModule(for project: Project, output: ProjectDetailModuleOutputProtocol)
    func pushAddProjectModule(output: ProjectEditModuleOutputProtocol)
    func close()
}

final class ProjectsRouter: ProjectsRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushDetailModule(for project: Project, output: ProjectDetailModuleOutputProtocol) {
        
        let detailModule = ProjectDetailModule.build(project: project, output: output)
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func pushAddProjectModule(output: ProjectEditModuleOutputProtocol) {
        let editModule = ProjectEditModule.build(output: output)
        editModule.input.createProject()
        viewController?.navigationController?.pushViewController(editModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
