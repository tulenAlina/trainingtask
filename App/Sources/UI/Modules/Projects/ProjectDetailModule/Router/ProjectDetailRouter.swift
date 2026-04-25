import UIKit

protocol ProjectDetailRouterInputProtocol {
    func openEditScreen(project: Project, moduleOutput: EditProjectModuleOutputProtocol)
    func openTasksScreen(project: Project)
    func close()
}

final class ProjectDetailRouter: ProjectDetailRouterInputProtocol {
    weak var viewController: UIViewController?

    func openEditScreen(project: Project, moduleOutput: EditProjectModuleOutputProtocol) {
        let editModuleViewController = EditProjectModule.build(moduleOutput: moduleOutput)
        editModuleViewController.input.updateProject(project: project)
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func openTasksScreen(project: Project) {
        let tasksModule = TasksModule.build(project: project)
        viewController?.navigationController?.pushViewController(tasksModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
