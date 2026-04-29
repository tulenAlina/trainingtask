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
        
        let displayedTask = TaskDisplayModel(
            taskName: task.taskName,
            projectName: project?.projectName ?? Localized.unknownProjectLabel,
            employeeName: employee?.fullName ?? Localized.notAssignedLabel,
            status: task.status,
            workTime: "\(task.workTime)",
            startDate: DateHelper.string(from: task.startDate),
            endDate: DateHelper.string(from: task.endDate)
        )
        
        view?.configure(with: displayedTask)
        output?.didUpdateTask(task, project: project, employee: employee)
    }
    
    func didCreateTask(_ task: ProjectTask) {
        // TaskDetailPresenter не обрабатывает создание задач, только обновление существующих.
        // Метод оставлен пустым для соответствия протоколу.
    }
}

// MARK: - TaskDetailViewOutputProtocol
extension TaskDetailPresenter: TaskDetailViewOutputProtocol {
    func viewDidLoad() {
        let displayedTask = TaskDisplayModel(
            taskName: task.taskName,
            projectName: project?.projectName ?? Localized.unknownProjectLabel,
            employeeName: employee?.fullName ?? Localized.notAssignedLabel,
            status: task.status,
            workTime: "\(task.workTime)",
            startDate: DateHelper.string(from: task.startDate),
            endDate: DateHelper.string(from: task.endDate)
        )
        view?.configure(with: displayedTask)
    }
    
    func didTapChangeButton() {
        router.pushEditModule(
            task: task,
            project: project,
            isOpenedFromProject: isOpenedFromProject,
            employee: employee,
            output: self
        )
    }
    
    func didTapDeleteButton() {
        output?.didDeleteTask(task.id)
        router.close()
    }
}

// MARK: - TaskDetailInteractorOutputProtocol
extension TaskDetailPresenter: TaskDetailInteractorOutputProtocol {}
