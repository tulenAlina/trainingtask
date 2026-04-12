import Foundation

protocol EditTaskPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapSaveButton(taskNameString: String, workTime: Int, startDateString: String, endDateString: String, statusIndex: Int)
    func didTapClearEmployee()
    func didTapSelectProject()
    func didTapSelectEmployee()
}

final class EditTaskPresenter: EditTaskPresenterProtocol {
    var onUpdate: ((ProjectTask) -> Void)?
    var onCreate: ((ProjectTask) -> Void)?
    
    var view: EditTaskViewProtocol
    let interactor: EditTaskInteractorProtocol
    let router: EditTaskRouterProtocol
    
    private var task: ProjectTask?
    private var contextProject: Project?
    private var projects: [Project] = []
    private var employees: [Employee] = []
    private var selectedProject: Project?
    private var selectedEmployee: Employee?
    
    private init(view: EditTaskViewProtocol, interactor: EditTaskInteractorProtocol, router: EditTaskRouterProtocol, task: ProjectTask? = nil, project: Project? = nil) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.task = task
        self.contextProject = project
        selectedProject = contextProject
    }
    
    convenience init(view: EditTaskViewProtocol, interactor: EditTaskInteractorProtocol, router: EditTaskRouterProtocol, task: ProjectTask? = nil, project: Project? = nil, onUpdate: @escaping ((ProjectTask) -> Void)) {
        self.init(view: view, interactor: interactor, router: router, task: task, project: project)
        self.onUpdate = onUpdate
    }
    
    convenience init(view: EditTaskViewProtocol, interactor: EditTaskInteractorProtocol, router: EditTaskRouterProtocol, task: ProjectTask? = nil, project: Project? = nil, onCreate: @escaping ((ProjectTask) -> Void)) {
        self.init(view: view, interactor: interactor, router: router, task: task, project: project)
        self.onCreate = onCreate
    }
    
    func viewDidLoad() {
        let title = (task != nil) ? Localized.editTask : Localized.addTask
        configureFields()
        configureStatus()
        view.setupNavigationBar(title: title)
        loadData()
    }
    
    private func configureFields() {
        if let contextProject {
            view.setProjectField(text: "\(contextProject.projectName)")
        }
        
        view.setEndDateField(defaultDaysBetween: interactor.defaultDaysBetween())
        
        if let task {
            selectedProject = contextProject ?? projects.first(where: { $0.id == task.projectID })
            selectedEmployee = employees.first(where: { $0.id == task.employeeID })
            
            let taskName = task.taskName
            let projectName = selectedProject?.projectName ?? ""
            let workTime = "\(task.workTime)"
            let startDate = DateHelper.string(from: task.startDate)
            let endDate = DateHelper.string(from: task.endDate)
            let employee = selectedEmployee?.fullName
        
            view.setTaskFields(
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
        view.setupSegmentedControl(index: index)
    }
    
    func didTapSaveButton(taskNameString: String, workTime: Int, startDateString: String, endDateString: String, statusIndex: Int) {
        guard view.validateFields() else { return }
        guard let selectedProject else { return }
        guard isFieldsChanged(
            taskNameString: taskNameString,
            projectID: selectedProject.id,
            workTime: workTime,
            startDateString: startDateString,
            endDateString: endDateString,
            statusIndex: statusIndex,
            employeeID: selectedEmployee?.id
        ) else {
            router.close()
            return
        }
        guard validateDates(startDateString: startDateString, endDateString: endDateString, workTime: workTime) else {return}
        view.startLoading()
        
        Task {
            do {
                let savedTask: ProjectTask
                if let task {
                    let updatedTask = updatedTask(
                        from: task,
                        newTaskName: taskNameString,
                        newProjectID: selectedProject.id,
                        newWorkTime: workTime,
                        newStartDateString: startDateString,
                        newEndDateString: endDateString,
                        newStatusIndex: statusIndex,
                        newEmployeeID: selectedEmployee?.id
                    )
                    savedTask = try await interactor.updateTask(updatedTask)
                } else {
                    let createdTask = buildTask(
                        newTaskName: taskNameString,
                        newProjectID: selectedProject.id,
                        newWorkTime: workTime,
                        newStartDateString: startDateString,
                        newEndDateString: endDateString,
                        newStatusIndex: statusIndex,
                        newEmployeeID: selectedEmployee?.id
                    )
                    savedTask = try await interactor.createTask(createdTask)
                }

                await MainActor.run {
                    if task != nil {
                        onUpdate?(savedTask)
                    } else {
                        onCreate?(savedTask)
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
    
    func isFieldsChanged(taskNameString: String, projectID: UUID, workTime: Int, startDateString: String, endDateString: String, statusIndex: Int, employeeID: UUID?) -> Bool {
        guard let task = task else { return true }
        
        var projectName: String = ""
        if let prj = projects.first(where: {$0.id == projectID}) {
            projectName = prj.projectName
        }
        
        var oldProjectName: String = ""
        if let prj = projects.first(where: {$0.id == task.projectID}) {
            oldProjectName = prj.projectName
        }
        
        var employeeFio: String = ""
        if let emp = employees.first(where: {$0.id == employeeID}) {
            employeeFio = emp.fullName
        }
        
        var oldEmployeeFio: String = ""
        if let emp = employees.first(where: {$0.id == task.employeeID}) {
            oldEmployeeFio = emp.fullName
        }
        
        let isTaskNameChanged = taskNameString != task.taskName.trimmed
        let isProjectChanged = projectName != oldProjectName
        let isWorkTimeChanged = workTime != task.workTime
        let isStartDateChanged = startDateString != DateHelper.string(from: task.startDate)
        let isEndDateChanged = endDateString != DateHelper.string(from: task.endDate)
        let isEmployeeChanged = employeeFio != oldEmployeeFio
        let isStatusChanged = statusIndex != TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
        return isTaskNameChanged || isProjectChanged || isWorkTimeChanged || isStartDateChanged || isEndDateChanged || isEmployeeChanged || isStatusChanged
    }
    
    private func prepareDisplayData() {
        guard let task else { return }
        
        selectedProject = contextProject ?? projects.first(where: { $0.id == task.projectID })
        let projectName = selectedProject?.projectName ?? ""
        
        selectedEmployee = employees.first(where: { $0.id == task.employeeID })
        let employeeName = selectedEmployee?.fullName
        
        view.updateUI(projectName: projectName, employeeName: employeeName)
    }
    
    private func updatedTask(
        from existingTask: ProjectTask,
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
        
        let updatedTask = ProjectTask(
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
        
        return updatedTask
    }
    
    private func buildTask(
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
    
    private func loadData() {
        view.startLoading()
        Task {
            do {
                let (projects, employees) = try await interactor.fetchData()
                
                self.projects = projects
                self.employees = employees
                
                await MainActor.run {
                    prepareDisplayData()
                }
            } catch {
                await MainActor.run {
                    view.stopLoading()
                    view.showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    private func validateDates(startDateString: String, endDateString: String, workTime: Int) -> Bool{
        guard let startDate = DateHelper.date(from: startDateString),
              let endDate = DateHelper.date(from: endDateString)
        else {
            view.showAlert(Localized.invalidDate)
            return false
        }
        
        guard endDate >= startDate else {
            view.showAlert(Localized.dateEndBeforeStart)
            return false
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let daysBetween = components.day ?? 0
        let maxHours = (daysBetween + 1) * 24
        
        let workTime = workTime
        
        guard workTime <= maxHours else {
            view.showAlert(Localized.hoursExceedPeriod)
            return false
        }
        
        return true
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

    func didSelectProject(_ project: Project) {
        selectedProject = project
        view.updateProjectName(project.projectName)
    }

    func didSelectEmployee(_ employee: Employee) {
        selectedEmployee = employee
        view.updateEmployeeName(employee.fullName)
    }
}
