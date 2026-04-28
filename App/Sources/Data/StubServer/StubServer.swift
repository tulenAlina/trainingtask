import Foundation

class StubServer: Server {
    enum Errors: Error {
        case itemNotFound
    }
    
    private let sleepTimeInNanoseconds: UInt64 = 1_000_000_000
    private var projects: [UUID: Project] = [:]
    private var employees: [UUID: Employee] = [:]
    private var tasks: [UUID: ProjectTask] = [:]
    
    init() {
        setupMockData()
    }
    
    // MARK: - Projects
    func fetchProjects() async throws -> [Project] {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        var result = Array(projects.values)
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    
    func createProject(_ project: Project) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        projects[project.id] = project
    }
    
    func updateProject(_ project: Project) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        if projects[project.id] == nil {
            throw Errors.itemNotFound
        }
        projects[project.id] = project
    }
    
    func deleteProject(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        guard let project = projects[id] else {
            throw Errors.itemNotFound
        }
        try removeAllTasksWithAssignments(of: project)
        
        projects[id] = nil
    }
    
    // MARK: - Employees
    func fetchEmployees() async throws -> [Employee] {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        var result = Array(employees.values)
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    
    func createEmployee(_ employee: Employee) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        employees[employee.id] = employee
    }
    
    func updateEmployee(_ employee: Employee) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        if employees[employee.id] == nil {
            throw Errors.itemNotFound
        }
        employees[employee.id] = employee
    }
    
    func deleteEmployee(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        guard let employee = employees[id] else {
            throw Errors.itemNotFound
        }
        try unassignEmployeeFromTasks(employee: employee)
        
        employees[id] = nil
    }
    
    // MARK: - Tasks
    func fetchTasks(projectID: UUID?) async throws -> [ProjectTask] {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        var result = Array(tasks.values)
        if let projectID {
            result = result.filter { $0.projectID == projectID }
        }
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    
    func createTask(_ task: ProjectTask) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        try addTaskToProject(projectID: task.projectID, taskID: task.id)
        tasks[task.id] = task
        
        guard let employeeID = task.employeeID else {
            return
        }
        try addTaskToEmployee(employeeID: employeeID, taskID: task.id)
    }
    
    func updateTask(_ task: ProjectTask) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        guard let oldTask = tasks[task.id] else {
            throw Errors.itemNotFound
        }
        
        try updateTaskProject(oldTask: oldTask, newTask: task)
        try updateTaskEmployee(oldTask: oldTask, newTask: task)
        tasks[task.id] = task
    }
    
    func deleteTask(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        guard let task = tasks[id] else {
            throw Errors.itemNotFound
        }
        
        try removeTaskFromProject(projectID: task.projectID, taskID: id)
        
        if let employeeID = task.employeeID {
            try removeTaskFromEmployee(employeeID: employeeID, taskID: id)
        }
        
        tasks[id] = nil
    }
}

// MARK: - Private Helpers
private extension StubServer {
    func addTaskToProject(projectID: UUID, taskID: UUID) throws {
        if let project = projects[projectID] {
            var newTasks = project.tasks
            newTasks.append(taskID)
            let newProject = createProject(from: project, newTasks: newTasks)
            projects[projectID] = newProject
        } else {
            throw Errors.itemNotFound
        }
    }
    
    func addTaskToEmployee(employeeID: UUID, taskID: UUID) throws {
        if let employee = employees[employeeID] {
            var newTasks = employee.tasks
            newTasks.append(taskID)
            let newEmployee = createEmployee(from: employee, newTasks: newTasks)
            employees[employeeID] = newEmployee
        } else {
            throw Errors.itemNotFound
        }
    }
    
    func updateTaskProject(oldTask: ProjectTask, newTask: ProjectTask) throws {
        guard oldTask.projectID != newTask.projectID else {
            return
        }
        
        try removeTaskFromProject(projectID: oldTask.projectID, taskID: oldTask.id)
        try addTaskToProject(projectID: newTask.projectID, taskID: newTask.id)
    }
    
    func updateTaskEmployee(oldTask: ProjectTask, newTask: ProjectTask) throws {
        guard oldTask.employeeID != newTask.employeeID else {
            return
        }
        
        if let employeeID = oldTask.employeeID {
            try removeTaskFromEmployee(employeeID: employeeID, taskID: oldTask.id)
        }
        
        if let employeeID = newTask.employeeID {
            try addTaskToEmployee(employeeID: employeeID, taskID: newTask.id)
        }
    }
    
    func removeTaskFromProject(projectID: UUID, taskID: UUID) throws {
        if let project = projects[projectID] {
            let newTasks = project.tasks.filter { $0 != taskID}
            let newProject = createProject(from: project, newTasks: newTasks)
            projects[projectID] = newProject
        } else {
            throw Errors.itemNotFound
        }
    }
    
    func removeTaskFromEmployee(employeeID: UUID, taskID: UUID) throws {
        if let employee = employees[employeeID] {
            let newTasks = employee.tasks.filter { $0 != taskID }
            let newEmployee = createEmployee(from: employee, newTasks: newTasks)
            employees[employeeID] = newEmployee
        } else {
            throw Errors.itemNotFound
        }
    }
    
    func unassignEmployeeFromTasks(employee: Employee) throws {
        var hasErrors = false
        
        for taskID in employee.tasks {
            guard let task = tasks[taskID] else {
                hasErrors = true
                continue
            }
            let newTask = createTask(from: task, newEmployeeID: nil)
            tasks[taskID] = newTask
        }
        
        if hasErrors {
            throw Errors.itemNotFound
        }
    }
    
    func removeAllTasksWithAssignments(of project: Project) throws {
        var hasErrors = false
        
        for taskID in project.tasks {
            guard let task = tasks[taskID] else {
                hasErrors = true
                continue
            }
            tasks[taskID] = nil
            
            guard let employeeID = task.employeeID else { continue }
            try removeTaskFromEmployee(employeeID: employeeID, taskID: taskID)
        }
        
        if hasErrors {
            throw Errors.itemNotFound
        }
    }
    
    func createProject(from existing: Project, newTasks: [UUID]) -> Project {
        Project(
            id: existing.id,
            projectName: existing.projectName,
            description: existing.description,
            tasks: newTasks,
            createdAt: existing.createdAt
        )
    }
    
    func createEmployee(from existing: Employee, newTasks: [UUID]) -> Employee {
        Employee(
            id: existing.id,
            firstName: existing.firstName,
            lastName: existing.lastName,
            surName: existing.surName,
            position: existing.position,
            tasks: newTasks,
            createdAt: existing.createdAt
        )
    }
    
    func createTask(from existing: ProjectTask, newEmployeeID: UUID?) -> ProjectTask {
        ProjectTask(
            id: existing.id,
            taskName: existing.taskName,
            projectID: existing.projectID,
            workTime: existing.workTime,
            startDate: existing.startDate,
            endDate: existing.endDate,
            status: existing.status,
            employeeID: newEmployeeID,
            createdAt: existing.createdAt
        )
    }
    
    // MARK: - Data
    func setupMockData() {
        for i in 0..<10 {
            let project = Project(projectName: "Project\(i)", description: "Description\(i)")
            let employee = Employee(firstName: "Name\(i)", lastName: "LastName\(i)", surName: "Surname\(i)", position: "Position\(i)")
            let task = ProjectTask(
                taskName: "Task\(i)",
                projectID: project.id,
                workTime: 5,
                startDate: Date(),
                endDate: Date(),
                status: .notStarted,
                employeeID: employee.id
            )
            
            var newProjectTasks = project.tasks
            newProjectTasks.append(task.id)
            let newProject = createProject(from: project, newTasks: newProjectTasks)
            
            var newEmployeeTasks = employee.tasks
            newEmployeeTasks.append(task.id)
            let newEmployee = createEmployee(from: employee, newTasks: newEmployeeTasks)

            projects[project.id] = newProject
            employees[employee.id] = newEmployee
            tasks[task.id] = task
        }
    }
}
