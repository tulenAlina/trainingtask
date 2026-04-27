import UIKit

protocol TaskDetailRouterInputProtocol {
    func pushEditScreen(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?, moduleOutput: EditTaskModuleOutputProtocol)
    func close()
}

final class TaskDetailRouter: TaskDetailRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushEditScreen(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?, moduleOutput: EditTaskModuleOutputProtocol) {
        let editModuleViewController = EditTaskModule.build(moduleOutput: moduleOutput)
        editModuleViewController.input.updateTask(task: task, project: project, isOpenedFromProject: isOpenedFromProject, employee: employee)
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
