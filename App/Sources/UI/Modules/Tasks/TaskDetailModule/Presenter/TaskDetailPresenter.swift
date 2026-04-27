import Foundation

final class TaskDetailPresenter: TaskDetailModuleInputProtocol {
    weak var view: TaskDetailViewInputProtocol?
    weak var output: TaskDetailModuleOutputProtocol?
    private let interactor: TaskDetailInteractorInputProtocol
    private var router: TaskDetailRouterInputProtocol
    
    private var task: ProjectTask
    private var project: Project?
    private var employee: Employee?
    private var isOpenedFromProject = false
    
    init(interactor: TaskDetailInteractorInputProtocol, router: TaskDetailRouterInputProtocol, task: ProjectTask, project: Project?, employee: Employee?, isOpenedFromProject: Bool) {
        self.interactor = interactor
        self.router = router
        self.task = task
        self.project = project
        self.isOpenedFromProject = isOpenedFromProject
        self.employee = employee
    }
}

// MARK: - EditTaskModuleOutputProtocol

extension TaskDetailPresenter: EditTaskModuleOutputProtocol {
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?) {
        self.task = task
        self.project = project
        self.employee = employee
        
        view?.configureLabels(
            taskName: task.taskName,
            projectName: project?.projectName ?? Localized.unknownProjectLabel,
            employeeName: employee?.fullName ?? Localized.notAssignedLabel,
            status: task.status,
            workTime: "\(task.workTime)",
            startDate: DateHelper.string(from: task.startDate),
            endDate: DateHelper.string(from: task.endDate)
        )
        output?.didUpdateTask(task, project: project, employee: employee)
    }
    
    func didCreateTask(_ task: ProjectTask) {}
}

// MARK: - TaskDetailViewOutputProtocol

extension TaskDetailPresenter: TaskDetailViewOutputProtocol {
    func viewDidLoad() {
        view?.configureLabels(
            taskName: task.taskName,
            projectName: project?.projectName ?? Localized.unknownProjectLabel,
            employeeName: employee?.fullName ?? Localized.notAssignedLabel,
            status: task.status,
            workTime: "\(task.workTime)",
            startDate: DateHelper.string(from: task.startDate),
            endDate: DateHelper.string(from: task.endDate)
        )
    }
    
    func didTapChangeButton() {
        router.pushEditScreen(
            task: task,
            project: project,
            isOpenedFromProject: isOpenedFromProject,
            employee: employee,
            moduleOutput: self
        )
    }
    
    func didTapDeleteButton() {
        output?.didDeleteTask(with: task.id)
        router.close()
    }
}
