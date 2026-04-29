import UIKit

protocol TaskDetailRouterInputProtocol {
    func pushEditModule(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?, output: EditTaskModuleOutputProtocol)
    func close()
}

final class TaskDetailRouter: TaskDetailRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushEditModule(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?, output: EditTaskModuleOutputProtocol) {
        let editModule = EditTaskModule.build(output: output)
        editModule.input.updateTask(task: task, project: project, isOpenedFromProject: isOpenedFromProject, employee: employee)
        viewController?.navigationController?.pushViewController(editModule.view, animated: true)
    }
    
    func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
