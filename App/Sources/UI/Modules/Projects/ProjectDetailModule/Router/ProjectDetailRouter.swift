import UIKit

protocol ProjectDetailRouterInputProtocol {
    func pushEditScreen(project: Project, output: EditProjectModuleOutputProtocol)
    func pushTasksScreen(project: Project)
    func close()
}

final class ProjectDetailRouter: ProjectDetailRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushEditScreen(project: Project, output: EditProjectModuleOutputProtocol) {
        let editModuleViewController = EditProjectModule.build(output: output)
        editModuleViewController.input.updateProject(project: project)
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func pushTasksScreen(project: Project) {
        let tasksModule = TasksModule.build(project: project)
        viewController?.navigationController?.pushViewController(tasksModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
