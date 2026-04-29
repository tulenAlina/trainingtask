import UIKit

protocol TaskDetailRouterInputProtocol {
    func pushEditModule(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?, output: TaskEditModuleOutputProtocol)
    func close()
}

final class TaskDetailRouter: TaskDetailRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushEditModule(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?, output: TaskEditModuleOutputProtocol) {
        let editModule = TaskEditModule.build(output: output)
        editModule.input.updateTask(task: task, project: project, isOpenedFromProject: isOpenedFromProject, employee: employee)
        viewController?.navigationController?.pushViewController(editModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
