import UIKit

protocol ProjectDetailRouterInputProtocol {
    func pushEditModule(project: Project, output: ProjectEditModuleOutputProtocol)
    func pushTasksModule(project: Project)
    func close()
}

final class ProjectDetailRouter: ProjectDetailRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushEditModule(project: Project, output: ProjectEditModuleOutputProtocol) {
        let editModule = ProjectEditModule.build(output: output)
        editModule.input.updateProject(project: project)
        viewController?.navigationController?.pushViewController(editModule.view, animated: true)
    }
    
    func pushTasksModule(project: Project) {
        let tasksModule = TasksModule.build(project: project)
        viewController?.navigationController?.pushViewController(tasksModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
