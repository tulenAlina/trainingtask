import UIKit

protocol TasksRouterInputProtocol {
    func pushDetailModule(for task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool, output: TaskDetailModuleOutputProtocol)
    func pushAddTaskModule(project: Project?, output: TaskEditModuleOutputProtocol)
}

final class TasksRouter: TasksRouterInputProtocol {
    weak var viewController: UIViewController?
    
    func pushDetailModule(
        for task: ProjectTask,
        project: Project?,
        employee: Employee?,
        isOpenedFromProject: Bool,
        output: TaskDetailModuleOutputProtocol
    ) {
        
        let detailModule = TaskDetailModule.build(
            task: task,
            project: project,
            employee: employee,
            isOpenedFromProject: isOpenedFromProject,
            output: output
        )
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func pushAddTaskModule(project: Project?, output: TaskEditModuleOutputProtocol) {
        let editModule = TaskEditModule.build(output: output)
        editModule.input.createTask(project: project)
        viewController?.navigationController?.pushViewController(editModule.view, animated: true)
    }
}
