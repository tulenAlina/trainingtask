import UIKit

protocol TasksRouterInputProtocol {
    func pushDetailScreen(for task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool, moduleOutput: TaskDetailModuleOutputProtocol)
    func pushAddTaskScreen(project: Project?, moduleOutput: EditTaskModuleOutputProtocol)
}

final class TasksRouter: TasksRouterInputProtocol {
    weak var viewController: UIViewController?

    func pushDetailScreen(
        for task: ProjectTask,
        project: Project?,
        employee: Employee?,
        isOpenedFromProject: Bool,
        moduleOutput: TaskDetailModuleOutputProtocol
    ) {
        
        let detailModule = TaskDetailModule.build(
            task: task,
            project: project,
            employee: employee,
            isOpenedFromProject: isOpenedFromProject,
            moduleOutput: moduleOutput
        )
        viewController?.navigationController?.pushViewController(detailModule.view, animated: true)
    }
    
    func pushAddTaskScreen(project: Project?, moduleOutput: EditTaskModuleOutputProtocol) {
        let editModuleViewController = EditTaskModule.build(moduleOutput: moduleOutput)
        editModuleViewController.input.createTask(project: project)
        viewController?.navigationController?.pushViewController(editModuleViewController.view, animated: true)
    }
}
