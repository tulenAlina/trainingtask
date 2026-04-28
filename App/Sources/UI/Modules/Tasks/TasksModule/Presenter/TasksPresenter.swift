import Foundation

struct TaskCellViewModel {
    let taskName: String
    let projectName: String?
    let status: TaskStatus
}

final class TasksPresenter: TasksModuleInputProtocol {
    weak var view: TasksViewInputProtocol?
    private let interactor: TasksInteractorInputProtocol
    private var router: TasksRouterInputProtocol
    
    private let project: Project?
    private var projects: [Project] = []
    private var employees: [Employee] = []
    
    init(interactor: TasksInteractorInputProtocol, router: TasksRouterInputProtocol, project: Project?) {
        self.interactor = interactor
        self.router = router
        self.project = project
    }
}

// MARK: - TasksViewOutputProtocol
extension TasksPresenter: TasksViewOutputProtocol {
    func viewDidLoad() {
        view?.startLoading()
        refreshData()
    }
    
    func didRefreshData() {
        refreshData()
    }
    
    func didTapTaskRow(task: ProjectTask) {
        let currentProject: Project?
        var isOpenedFromProject = false
        
        if let project {
            currentProject = project
            isOpenedFromProject = true
        } else {
            currentProject = projects.first { $0.id == task.projectID }
        }
        
        let currentEmployee = employees.first { $0.id == task.employeeID }
        
        router.pushDetailScreen(for: task, project: currentProject, employee: currentEmployee, isOpenedFromProject: isOpenedFromProject, output: self)
    }
    
    func didTapAddButton() {
        router.pushAddTaskScreen(project: project, output: self)
    }
    
    func viewModelForTask(at index: Int) -> TaskCellViewModel? {
        guard let view else {
            return nil
        }
        
        let task = view.getItem(at: index)
        
        var projectName: String? = nil
        if project == nil {
            projectName = projects.first(where: {$0.id == task.projectID})?.projectName
        }
        
        return TaskCellViewModel(taskName: task.taskName, projectName: projectName, status: task.status)
    }
}

// MARK: - EditTaskModuleOutputProtocol
extension TasksPresenter: EditTaskModuleOutputProtocol {
    func didCreateTask(_ task: ProjectTask) {
        view?.addItem(task)
    }
    
    func didUpdateTask(_ task: ProjectTask, project: Project?, employee: Employee?) {
        view?.updateItem(task) { $0.id == task.id }
    }
}

// MARK: - TaskDetailModuleOutputProtocol
extension TasksPresenter: TaskDetailModuleOutputProtocol {
    func didDeleteTask(_ taskID: UUID) {
        deleteTask(taskID)
    }
}

// MARK: - Private
private extension TasksPresenter {
    func loadData() async throws {
        let (tasks, projects, employees) = try await interactor.fetchData(projectID: project?.id)
        view?.setItems(tasks)
        self.projects = projects ?? []
        self.employees = employees
    }
    
    func refreshData() {
        Task {
            do {
                try await loadData()
                await MainActor.run {
                    view?.updateUI()
                }
            } catch {
                await MainActor.run {
                    view?.stopLoading()
                    view?.endRefreshing()
                    view?.showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    func deleteTask(_ taskID: UUID) {
        view?.startLoading()
        guard let index = view?.firstIndex(where: { $0.id == taskID }) else { return }

        Task {
            do {
                try await interactor.deleteTask(taskID)
                await MainActor.run {
                    view?.deleteItem(at: index)
                    view?.updateUI()
                }
            } catch {
                await MainActor.run {
                    view?.stopLoading()
                    view?.showAlert(Localized.deleteFailed)
                }
            }
        }
    }
}
