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
    
    func createProject(_ project: Project) async throws -> Project {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        projects[project.id] = project
        
        return project
    }
    
    func updateProject(_ project: Project) async throws -> Project {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        if projects[project.id] == nil {
            throw Errors.itemNotFound
        }
        projects[project.id] = project
        
        return project
    }
    
    func deleteProject(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        guard let project = projects[id] else {
            throw Errors.itemNotFound
        }
        removeAllTasks(of: project)
        
        projects[id] = nil
    }
    
    // MARK: - Employees
    
    func fetchEmployees() async throws -> [Employee] {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        var result = Array(employees.values)
        result = result.sorted { $0.createdAt > $1.createdAt }
        
        return result
    }
    
    func createEmployee(_ employee: Employee) async throws -> Employee {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        employees[employee.id] = employee
        
        return employee
    }
    
    func updateEmployee(_ employee: Employee) async throws -> Employee {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        if employees[employee.id] == nil {
            throw Errors.itemNotFound
        }
        employees[employee.id] = employee
        
        return employee
    }
    
    func deleteEmployee(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        guard let employee = employees[id] else {
            throw Errors.itemNotFound
        }
        removeEmployeeFromTasks(employee: employee)
        
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
    
    func createTask(_ task: ProjectTask) async throws -> ProjectTask {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        addTaskToProject(projectID: task.projectID, taskID: task.id)
        tasks[task.id] = task
        
        guard let employeeID = task.employeeID else {
            return task
        }
        addTaskToEmployee(employeeID: employeeID, taskID: task.id)
        
        return task
    }
    
    func updateTask(_ task: ProjectTask) async throws -> ProjectTask {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        guard let oldTask = tasks[task.id] else {
            throw Errors.itemNotFound
        }
        
        updateTaskProject(oldTask: oldTask, newTask: task)
        updateTaskEmployee(oldTask: oldTask, newTask: task)
        tasks[task.id] = task
        
        return task
    }
    
    func deleteTask(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        guard let task = tasks[id] else {
            throw Errors.itemNotFound
        }
        
        removeTaskFromProject(projectID: task.projectID, taskID: id)
        
        if let employeeID = task.employeeID {
            removeTaskFromEmployee(employeeID: employeeID, taskID: id)
        }
        
        tasks[id] = nil
    }
    
    // MARK: - Helpers
    
    private func addTaskToProject(projectID: UUID, taskID: UUID) {
        if let project = projects[projectID] {
            var newTasks = project.tasks
            newTasks.append(taskID)
            let newProject = makeProject(from: project, newTasks: newTasks)
            projects[projectID] = newProject
        }
    }
    
    private func addTaskToEmployee(employeeID: UUID, taskID: UUID) {
        if let employee = employees[employeeID] {
            var newTasks = employee.tasks
            newTasks.append(taskID)
            let newEmployee = makeEmployee(from: employee, newTasks: newTasks)
            employees[employeeID] = newEmployee
        }
    }
    
    private func updateTaskProject(oldTask: ProjectTask, newTask: ProjectTask) {
        guard oldTask.projectID != newTask.projectID else {
            return
        }
        
        removeTaskFromProject(projectID: oldTask.projectID, taskID: oldTask.id)
        addTaskToProject(projectID: newTask.projectID, taskID: newTask.id)
    }
    
    private func updateTaskEmployee(oldTask: ProjectTask, newTask: ProjectTask) {
        guard oldTask.employeeID != newTask.employeeID else {
            return
        }
        
        if let employeeID = oldTask.employeeID {
            removeTaskFromEmployee(employeeID: employeeID, taskID: oldTask.id)
        }
        
        if let employeeID = newTask.employeeID {
            addTaskToEmployee(employeeID: employeeID, taskID: newTask.id)
        }
    }
    
    private func removeTaskFromProject(projectID: UUID, taskID: UUID) {
        if let project = projects[projectID] {
            let newTasks = project.tasks.filter { $0 != taskID}
            let newProject = makeProject(from: project, newTasks: newTasks)
            projects[projectID] = newProject
        }
    }
    
    private func removeTaskFromEmployee(employeeID: UUID, taskID: UUID) {
        if let employee = employees[employeeID] {
            let newTasks = employee.tasks.filter { $0 != taskID }
            let newEmployee = makeEmployee(from: employee, newTasks: newTasks)
            employees[employeeID] = newEmployee
        }
    }
    
    private func removeEmployeeFromTasks(employee: Employee) {
        for taskID in employee.tasks {
            guard let task = tasks[taskID] else { continue }
            let newTask = makeTask(from: task, newEmployeeID: nil)
            tasks[taskID] = newTask
        }
    }
    
    private func removeAllTasks(of project: Project) {
        for taskID in project.tasks {
            guard let task = tasks[taskID] else { continue }
            tasks[taskID] = nil
            
            guard let employeeID = task.employeeID else { continue }
            removeTaskFromEmployee(employeeID: employeeID, taskID: taskID)
        }
    }
    
    private func makeProject(from existing: Project, newTasks: [UUID]) -> Project {
        return Project(
            id: existing.id,
            projectName: existing.projectName,
            description: existing.description,
            tasks: newTasks,
            createdAt: existing.createdAt
        )
    }
    
    private func makeEmployee(from existing: Employee, newTasks: [UUID]) -> Employee {
        return Employee(
            id: existing.id,
            firstName: existing.firstName,
            lastName: existing.lastName,
            surName: existing.surName,
            position: existing.position,
            tasks: newTasks,
            createdAt: existing.createdAt
        )
    }
    
    private func makeTask(from existing: ProjectTask, newEmployeeID: UUID?) -> ProjectTask {
        return ProjectTask(
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
    
    private func setupMockData() {
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
            let newProject = makeProject(from: project, newTasks: newProjectTasks)
            
            var newEmployeeTasks = employee.tasks
            newEmployeeTasks.append(task.id)
            let newEmployee = makeEmployee(from: employee, newTasks: newEmployeeTasks)

            projects[project.id] = newProject
            employees[employee.id] = newEmployee
            tasks[task.id] = task
        }
    }
}
