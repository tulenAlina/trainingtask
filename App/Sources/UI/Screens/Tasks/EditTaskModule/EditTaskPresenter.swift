import Foundation

protocol EditTaskPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapSaveButton(taskNameString: String, workTime: String, startDateString: String, endDateString: String, statusIndex: Int)
    func didTapClearEmployee()
    func didTapSelectProject()
    func didTapSelectEmployee()
}

final class EditTaskPresenter {
    weak var view: EditTaskViewProtocol?
    
    private let interactor: EditTaskInteractorProtocol
    private let router: EditTaskRouterProtocol
    private let action: EditTaskAction
    
    private var task: ProjectTask?
    private var contextProject: Project?
    private var projects: [Project] = []
    private var employees: [Employee] = []
    private var selectedProject: Project?
    private var selectedEmployee: Employee?
    
    init(interactor: EditTaskInteractorProtocol, router: EditTaskRouterProtocol, task: ProjectTask? = nil, project: Project? = nil, action: EditTaskAction)
    {
        self.interactor = interactor
        self.router = router
        self.task = task
        self.contextProject = project
        self.action = action
        selectedProject = contextProject
    }
    
    private func isFieldsChanged(taskNameString: String, projectID: UUID, workTime: Int, startDateString: String, endDateString: String, statusIndex: Int, employeeID: UUID?) -> Bool {
        guard let task = task else { return true }
        
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
        selectedProject = project
        view?.updateProjectName(project.projectName)
    }

    private func didSelectEmployee(_ employee: Employee) {
        selectedEmployee = employee
        view?.updateEmployeeName(employee.fullName)
    }
    
    private func configureFields() {
        if let contextProject {
            view?.setProjectField(text: "\(contextProject.projectName)")
        }
        
        view?.setEndDateField(defaultDaysBetween: interactor.defaultDaysBetween())
        
        if let task {
            selectedProject = contextProject ?? projects.first(where: { $0.id == task.projectID })
            selectedEmployee = employees.first(where: { $0.id == task.employeeID })
            
            let taskName = task.taskName
            let projectName = selectedProject?.projectName ?? ""
            let workTime = "\(task.workTime)"
            let startDate = DateHelper.string(from: task.startDate)
            let endDate = DateHelper.string(from: task.endDate)
            let employee = selectedEmployee?.fullName
        
            view?.setTaskFields(
                taskName: taskName,
                projectName: projectName,
                workTime: workTime,
                startDate: startDate,
                endDate: endDate,
                employee: employee
            )
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
    
    private func updateData() {
        guard let task else { return }
        
        selectedProject = contextProject ?? projects.first(where: { $0.id == task.projectID })
        selectedEmployee = employees.first(where: { $0.id == task.employeeID })
        
    }
    
    private func getDisplayNames() -> (String?, String?) {
        let projectName = selectedProject?.projectName ?? ""
        let employeeName = selectedEmployee?.fullName
        
        return (projectName, employeeName)
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
    
    private func loadData() {
        view?.startLoading()
        Task {
            do {
                let (projects, employees) = try await interactor.fetchData()
                
                self.projects = projects
                self.employees = employees
                
                await MainActor.run {
                    updateData()
                    let (projectName, employeeName) = getDisplayNames()
                    view?.updateUI(projectName: projectName, employeeName: employeeName)
                    view?.stopLoading()
                }
            } catch {
                await MainActor.run {
                    view?.stopLoading()
                    view?.showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    private func validateFields(taskNameString: String, projectName: String?, workTime: String) -> Bool {
        guard let view else { return false }
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
}

extension EditTaskPresenter: EditTaskPresenterProtocol {
    func viewDidLoad() {
        let title = (task != nil) ? Localized.editTask : Localized.addTask
        configureFields()
        configureStatus()
        view?.setupNavigationBar(title: title)
        loadData()
    }
    
    private func validateTask(taskNameString: String, workTime: String, startDateString: String, endDateString: String, statusIndex: Int) -> Bool {
        guard validateFields(taskNameString: taskNameString, projectName: selectedProject?.projectName, workTime: workTime) else {
            view?.showAlert(Localized.emptyFields)
            return false
        }
        guard validateDates(startDateString: startDateString, endDateString: endDateString, workTime: workTime.cleanedInt) else { return false }
        return true
    }
    
    func didTapSaveButton(taskNameString: String, workTime: String, startDateString: String, endDateString: String, statusIndex: Int) {
        guard let view, validateTask(taskNameString: taskNameString, workTime: workTime, startDateString: startDateString, endDateString: endDateString, statusIndex: statusIndex), let selectedProject else { return }
        
        guard isFieldsChanged(taskNameString: taskNameString, projectID: selectedProject.id, workTime: workTime.cleanedInt, startDateString: startDateString, endDateString: endDateString, statusIndex: statusIndex, employeeID: selectedEmployee?.id
        ) else {
            router.close()
            return
        }
        
        view.startLoading()
        let isUpdate = task != nil
        
        Task {
            do {
                let newTask = createTask(from: task, newTaskName: taskNameString, newProjectID: selectedProject.id, newWorkTime: workTime.cleanedInt, newStartDateString: startDateString, newEndDateString: endDateString, newStatusIndex: statusIndex, newEmployeeID: selectedEmployee?.id)
                let savedTask = isUpdate ? try await interactor.updateTask(newTask) : try await interactor.createTask(newTask)

                await MainActor.run {
                    switch self.action {
                    case .create(let onCreate):
                        onCreate(savedTask)
                    case .update(let onUpdate):
                        onUpdate(savedTask)
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
        selectedEmployee = nil
    }
}
