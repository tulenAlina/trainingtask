import UIKit

protocol TasksRouterInputProtocol {
    func pushDetailScreen(for task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool, output: TaskDetailModuleOutputProtocol)
    func pushAddTaskScreen(project: Project?, output: EditTaskModuleOutputProtocol)
}

final class TasksRouter: TasksRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushDetailScreen(
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
    
    func pushAddTaskScreen(project: Project?, output: EditTaskModuleOutputProtocol) {
        let editModuleViewController = EditTaskModule.build(output: output)
        editModuleViewController.input.createTask(project: project)
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
}
