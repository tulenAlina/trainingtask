import Foundation

final class EditTaskPresenter {
    weak var view: EditTaskViewInputProtocol?
    weak var moduleOutput: EditTaskModuleOutputProtocol?
    private let interactor: EditTaskInteractorInputProtocol
    private let router: EditTaskRouterInputProtocol
    
    private var action: EditTaskActionType = .create
    private var task: ProjectTask?
    private var project: Project?
    private var employee: Employee?
    private var isOpenedFromProject = false
    
    init(interactor: EditTaskInteractorInputProtocol, router: EditTaskRouterInputProtocol)
    {
        self.interactor = interactor
        self.router = router
    }
    
    private func isFieldsChanged(taskNameString: String, projectID: UUID, workTime: Int, startDateString: String, endDateString: String, statusIndex: Int, employeeID: UUID?) -> Bool {
        guard let task = task else {
            return true
        }
        
        let isTaskNameChanged = taskNameString != task.taskName.trimmed
        let isProjectChanged = projectID != task.projectID
        let isWorkTimeChanged = workTime != task.workTime
        let isStartDateChanged = startDateString != DateHelper.string(from: task.startDate)
        let isEndDateChanged = endDateString != DateHelper.string(from: task.endDate)
        let isEmployeeChanged = employeeID != task.employeeID
        let isStatusChanged = statusIndex != TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
        
        return isTaskNameChanged || isProjectChanged || isWorkTimeChanged || isStartDateChanged || isEndDateChanged || isEmployeeChanged || isStatusChanged
    }

    private func didSelectProject(_ project: Project) {
        self.project = project
        view?.updateProjectName(project.projectName)
    }

    private func didSelectEmployee(_ employee: Employee) {
        self.employee = employee
        view?.updateEmployeeName(employee.fullName)
    }
    
    private func configureFields() {
        view?.setEndDateField(defaultDaysBetween: interactor.defaultDaysBetween())
        
        if let task {
            let taskName = task.taskName
            let projectName = project?.projectName ?? ""
            let workTime = "\(task.workTime)"
            let startDate = DateHelper.string(from: task.startDate)
            let endDate = DateHelper.string(from: task.endDate)
            let employee = employee?.fullName
        
            view?.setTaskFields(
                taskName: taskName,
                projectName: projectName,
                workTime: workTime,
                startDate: startDate,
                endDate: endDate,
                employee: employee
            )
        }
        
        if let project, isOpenedFromProject {
            view?.setProjectField(projectName: "\(project.projectName)")
        }
    }
    
    private func configureStatus() {
        let index: Int
        if let task {
            index = TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
        } else {
            index = 0
        }
        view?.setupSegmentedControl(index: index)
    }
    
    private func createTask(
        from existingTask: ProjectTask? = nil,
        newTaskName: String,
        newProjectID: UUID,
        newWorkTime: Int,
        newStartDateString: String,
        newEndDateString: String,
        newStatusIndex: Int,
        newEmployeeID: UUID?
    ) -> ProjectTask {
        let newStatus = TaskStatus.allCases[newStatusIndex]
        let newStartDate = DateHelper.date(from: newStartDateString) ?? Date()
        let newEndDate = DateHelper.date(from: newEndDateString) ?? Calendar.current.date(byAdding: .day, value: interactor.defaultDaysBetween(), to: Date()) ?? Date()
        
        if let existingTask {
            return ProjectTask(
                id: existingTask.id,
                taskName: newTaskName,
                projectID: newProjectID,
                workTime: newWorkTime,
                startDate: newStartDate,
                endDate: newEndDate,
                status: newStatus,
                employeeID: newEmployeeID,
                createdAt: existingTask.createdAt
            )
        } else {
            return ProjectTask(
                taskName: newTaskName,
                projectID: newProjectID,
                workTime: newWorkTime,
                startDate: newStartDate,
                endDate: newEndDate,
                status: newStatus,
                employeeID: newEmployeeID
            )
        }
    }

    private func validateFields(taskNameString: String, projectName: String?, workTime: String) -> Bool {
        guard let view else {
            return false
        }
        var fieldsValidity: [Bool] = []
        var isValid = true
        
        for text in [taskNameString, projectName, workTime]
        {
            if text == nil || text?.isBlank == true {
                fieldsValidity.append(false)
                isValid = false
            } else {
                fieldsValidity.append(true)
            }
        }
        view.applyValidationResults(fieldsValidity)
        
        return isValid
    }
    
    private func validateDates(startDateString: String, endDateString: String, workTime: Int) -> Bool{
        guard let startDate = DateHelper.date(from: startDateString),
              let endDate = DateHelper.date(from: endDateString)
        else {
            view?.showAlert(Localized.invalidDate)
            return false
        }
        
        guard endDate >= startDate else {
            view?.showAlert(Localized.dateEndBeforeStart)
            return false
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let daysBetween = components.day ?? 0
        let maxHours = (daysBetween + 1) * 24
        
        let workTime = workTime
        
        guard workTime <= maxHours else {
            view?.showAlert(Localized.hoursExceedPeriod)
            return false
        }
        
        return true
    }
    
    private func validateTask(taskNameString: String, workTime: String, startDateString: String, endDateString: String, statusIndex: Int) -> Bool {
        guard validateFields(taskNameString: taskNameString, projectName: project?.projectName, workTime: workTime) else {
            view?.showAlert(Localized.emptyFields)
            return false
        }
        guard validateDates(startDateString: startDateString, endDateString: endDateString, workTime: workTime.cleanedInt) else {
            return false
        }
        return true
    }
}

extension EditTaskPresenter: EditTaskViewOutputProtocol {
    func viewDidLoad() {
        let title = (task != nil) ? Localized.editTask : Localized.addTask
        configureFields()
        configureStatus()
        view?.setupNavigationBar(title: title)
    }
    
    func didTapSaveButton(taskNameString: String, workTime: String, startDateString: String, endDateString: String, statusIndex: Int) {
        guard let view, validateTask(taskNameString: taskNameString, workTime: workTime, startDateString: startDateString, endDateString: endDateString, statusIndex: statusIndex), let project else {
            return
        }
        
        guard isFieldsChanged(taskNameString: taskNameString, projectID: project.id, workTime: workTime.cleanedInt, startDateString: startDateString, endDateString: endDateString, statusIndex: statusIndex, employeeID: employee?.id
        ) else {
            router.close()
            return
        }
        
        view.startLoading()
        let isUpdate = task != nil
        
        Task {
            do {
                let newTask = createTask(from: task, newTaskName: taskNameString, newProjectID: project.id, newWorkTime: workTime.cleanedInt, newStartDateString: startDateString, newEndDateString: endDateString, newStatusIndex: statusIndex, newEmployeeID: employee?.id)
                let savedTask = isUpdate ? try await interactor.updateTask(newTask) : try await interactor.createTask(newTask)

                await MainActor.run {
                    switch self.action {
                    case .create:
                        moduleOutput?.didCreateTask(savedTask)
                    case .update:
                        moduleOutput?.didUpdateTask(savedTask, project: project, employee: employee)
                                        }
                    view.stopLoading()
                    router.close()
                }
            } catch {
                await MainActor.run {
                    view.stopLoading()
                    view.showAlert(Localized.saveFailed)
                }
            }
        }
    }
    
    func didTapSelectProject() {
        router.navigateToProjectSelection { [weak self] project in
            self?.didSelectProject(project)
        }
    }

    func didTapSelectEmployee() {
        router.navigateToEmployeeSelection { [weak self] employee in
            self?.didSelectEmployee(employee)
        }
    }
    
    func didTapClearEmployee() {
        employee = nil
    }
}

extension EditTaskPresenter: EditTaskInteractorOutputProtocol {
}

extension EditTaskPresenter: EditTaskModuleInputProtocol {
    func configureForCreate(project: Project?) {
        self.task = nil
        self.project = project
        self.isOpenedFromProject = project != nil ? true : false
        self.employee = nil
        self.action = .create
    }
    
    func configureForUpdate(task: ProjectTask, project: Project?, isOpenedFromProject: Bool, employee: Employee?) {
        self.task = task
        self.project = project
        self.isOpenedFromProject = isOpenedFromProject
        self.employee = employee
        self.action = .update
    }
}
