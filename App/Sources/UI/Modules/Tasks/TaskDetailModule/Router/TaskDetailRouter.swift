import UIKit

protocol TaskDetailRouterInputProtocol {
    func pushEditScreen(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?, output: EditTaskModuleOutputProtocol)
    func close()
}

final class TaskDetailRouter: TaskDetailRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushEditScreen(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?, output: EditTaskModuleOutputProtocol) {
        let editModuleViewController = EditTaskModule.build(output: output)
        editModuleViewController.input.updateTask(task: task, project: project, isOpenedFromProject: isOpenedFromProject, employee: employee)
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
