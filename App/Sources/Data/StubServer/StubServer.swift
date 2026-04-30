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
    func loadProjects() async throws -> [Project] {
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
        let project = try validatedProject(project.id)
        projects[project.id] = project
    }
    
    func deleteProject(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        let project = try validatedProject(id)
        try removeAllTasksWithAssignments(of: project)
        
        projects[id] = nil
    }
    
    // MARK: - Employees
    func loadEmployees() async throws -> [Employee] {
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
        let employee = try validatedEmployee(employee.id)
        employees[employee.id] = employee
    }
    
    func deleteEmployee(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        let employee = try validatedEmployee(id)
        unassignEmployeeFromTasks(employee: employee)
        
        employees[id] = nil
    }
    
    // MARK: - Tasks
    func loadTasks(projectID: UUID?) async throws -> [ProjectTask] {
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
        let oldTask = try validatedTask(task.id)
        
        if oldTask.projectID != task.projectID {
            try updateTaskProject(
                taskID: task.id,
                from: oldTask.projectID,
                to: task.projectID
            )
        }
        if oldTask.employeeID != task.employeeID {
            try updateTaskEmployee(
                taskID: task.id,
                from: oldTask.employeeID,
                to: task.employeeID
            )
        }
        tasks[task.id] = task
    }
    
    func deleteTask(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleepTimeInNanoseconds)
        let task = try validatedTask(id)
        
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
    
    func updateTaskProject(taskID: UUID, from oldProjectID: UUID, to newProjectID: UUID) throws {
        try removeTaskFromProject(projectID: oldProjectID, taskID: taskID)
        try addTaskToProject(projectID: newProjectID, taskID: taskID)
    }
    
    func updateTaskEmployee(taskID: UUID, from oldEmployeeID: UUID?, to newEmployeeID: UUID?) throws {
        if let oldEmployeeID {
            try removeTaskFromEmployee(employeeID: oldEmployeeID, taskID: taskID)
        }
        
        if let newEmployeeID {
            try addTaskToEmployee(employeeID: newEmployeeID, taskID: taskID)
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
    
    func unassignEmployeeFromTasks(employee: Employee) {
        for taskID in employee.tasks {
            if let task = tasks[taskID] {
                tasks[taskID] = createTask(from: task, newEmployeeID: nil)
            }
        }
    }
    
    func removeAllTasksWithAssignments(of project: Project) throws {
        for taskID in project.tasks {
            guard let task = tasks[taskID] else {
                continue
            }
            tasks[taskID] = nil
            
            if let employeeID = task.employeeID {
                try removeTaskFromEmployee(employeeID: employeeID, taskID: taskID)
            }
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
    
    // MARK: - Validation
    func validatedProject(_ id: UUID) throws -> Project {
        guard let project = projects[id] else {
            throw Errors.itemNotFound
        }
        return project
    }
    
    func validatedTask(_ id: UUID) throws -> ProjectTask {
        guard let task = tasks[id] else {
            throw Errors.itemNotFound
        }
        return task
    }
    
    func validatedEmployee(_ id: UUID) throws -> Employee {
        guard let employee = employees[id] else {
            throw Errors.itemNotFound
        }
        return employee
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
