import Foundation

class StubServer: Server {
    
    enum Errors: Error {
        case itemNotFound
    }
    
    private let sleeepTimeInNanoseconds: UInt64 = 1_000_000_000
    private var projects: [UUID:Project] = [:]
    private var employees: [UUID:Employee] = [:]
    private var tasks: [UUID:ProjectTask] = [:]
    
    init() {
        setupMockData()
    }
    
    // MARK: - Projects
    func fetchProjects() async throws -> [Project] {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        var result = Array(projects.values)
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    
    func createProject(_ project: Project) async throws -> Project {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        projects[project.id] = project
        return project
    }
    
    func updateProject(_ project: Project) async throws -> Project {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        if projects[project.id] == nil {
            throw Errors.itemNotFound
        }
        
        projects[project.id] = project
        return project
    }
    
    func deleteProject(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        guard let project = projects[id] else {
            throw Errors.itemNotFound
        }
        
        for taskID in project.tasks {
            guard let task = tasks[taskID], let employeeID = task.employeeID, let employee = employees[employeeID] else { continue }
            let newEmployee = Employee(
                id: employee.id,
                firstName: employee.firstName,
                lastName: employee.lastName,
                surName: employee.surName,
                position: employee.position,
                tasks: employee.tasks.filter {$0 != task.id},
                createdAt: employee.createdAt
            )
            employees[employee.id] = newEmployee
        
            tasks[taskID] = nil
        }
        projects[id] = nil
    }
    
    // MARK: - Employees
    func fetchEmployees() async throws -> [Employee] {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        var result = Array(employees.values)
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    
    func createEmployee(_ employee: Employee) async throws -> Employee {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        employees[employee.id] = employee
        return employee
    }
    
    func updateEmployee(_ employee: Employee) async throws -> Employee {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        if employees[employee.id] == nil {
            throw Errors.itemNotFound
        }
        
        employees[employee.id] = employee
        return employee
    }
    
    func deleteEmployee(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        guard let employee = employees[id] else {
            throw Errors.itemNotFound
        }
        
        for taskID in employee.tasks {
            guard let task = tasks[taskID] else { continue }
            let newTask = ProjectTask(
                id: task.id,
                taskName: task.taskName,
                projectID: task.projectID,
                workTime: task.workTime,
                startDate: task.startDate,
                endDate: task.endDate,
                status: task.status,
                employeeID: nil,
                createdAt: task.createdAt
            )
            tasks[taskID] = newTask
        }
        employees[id] = nil
    }
    
    // MARK: - Tasks
    func fetchTasks(projectID: UUID?) async throws -> [ProjectTask] {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        var result = Array(tasks.values)
        if let projectID {
            result = result.filter {$0.projectID == projectID}
        }
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    
    func createTask(_ task: ProjectTask) async throws -> ProjectTask {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        tasks[task.id] = task
        
        if let project = projects[task.projectID] {
            var newTasks = project.tasks
            newTasks.append(task.id)
            let newProject = Project(
                id: project.id,
                projectName: project.projectName,
                description: project.description,
                tasks: newTasks,
                createdAt: project.createdAt
            )
            
            projects[task.projectID] = project
        }
        
        guard let employeeID = task.employeeID else {return task}
        if let employee = employees[employeeID] {
            var newTasks = employee.tasks
            newTasks.append(task.id)
            let newEmployee = Employee(
                id: employee.id,
                firstName: employee.firstName,
                lastName: employee.lastName,
                surName: employee.surName,
                position: employee.position,
                tasks: newTasks,
                createdAt: employee.createdAt
            )

            employees[employeeID] = employee
        }
        return task
    }
    
    func updateTask(_ task: ProjectTask) async throws -> ProjectTask {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        guard let oldTask = tasks[task.id] else {
            throw Errors.itemNotFound
        }
        
        if oldTask.projectID != task.projectID {
            if let project = projects[oldTask.projectID] {
                let newProject = Project(
                    id: project.id,
                    projectName: project.projectName,
                    description: project.description,
                    tasks: project.tasks.filter {$0 != task.id},
                    createdAt: project.createdAt
                )
                
                projects[oldTask.projectID] = newProject
            }
            
            if let project = projects[task.projectID]
            {
                var newTasks = project.tasks
                newTasks.append(task.id)
                let newProject = Project(
                    id: project.id,
                    projectName: project.projectName,
                    description: project.description,
                    tasks: newTasks,
                    createdAt: project.createdAt
                )
                
                projects[task.projectID] = newProject
            }
        }
        
        if oldTask.employeeID != task.employeeID {
            if let employeeID = oldTask.employeeID, var employee = employees[employeeID] {
                let newEmployee = Employee(
                    id: employee.id,
                    firstName: employee.firstName,
                    lastName: employee.lastName,
                    surName: employee.surName,
                    position: employee.position,
                    tasks: employee.tasks.filter {$0 != task.id},
                    createdAt: employee.createdAt
                )
                
                employees[employeeID] = newEmployee
            }
            
            if let employeeID = task.employeeID, var employee = employees[employeeID]
            {
                var newTasks = employee.tasks
                newTasks.append(task.id)
                let newEmployee = Employee(
                    id: employee.id,
                    firstName: employee.firstName,
                    lastName: employee.lastName,
                    surName: employee.surName,
                    position: employee.position,
                    tasks: newTasks,
                    createdAt: employee.createdAt
                )
                
                employees[employeeID] = newEmployee
            }
        }
        
        tasks[task.id] = task
        return task
    }
    
    func deleteTask(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        guard let task = tasks[id] else {
            throw Errors.itemNotFound
        }
        
        if var project = projects[task.projectID] {
            let newProject = Project(
                id: project.id,
                projectName: project.projectName,
                description: project.description,
                tasks: project.tasks.filter {$0 != task.id},
                createdAt: project.createdAt
            )
            
            projects[task.projectID] = newProject
        }
        
        if let employeeID = task.employeeID, var employee = employees[employeeID] {
            let newEmployee = Employee(
                id: employee.id,
                firstName: employee.firstName,
                lastName: employee.lastName,
                surName: employee.surName,
                position: employee.position,
                tasks: employee.tasks.filter {$0 != task.id},
                createdAt: employee.createdAt
            )
            employees[employeeID] = newEmployee
        }
        
        tasks[id] = nil
    }
    
    // MARK: - Data
    private func setupMockData() {
        for i in 0..<10 {
            var project = Project(projectName: "Project\(i)", description: "Description\(i)")
            var employee = Employee(firstName: "Name\(i)", lastName: "LastName\(i)", surName: "Surname\(i)", position: "Position\(i)")
            let task = ProjectTask(taskName: "Task\(i)", projectID: project.id, workTime: 5, startDate: Date(), endDate: Date(), status: .notStarted, employeeID: employee.id)
            
            var newProjectTasks = project.tasks
            newProjectTasks.append(task.id)
            let newProject = Project(
                id: project.id,
                projectName: project.projectName,
                description: project.description,
                tasks: newProjectTasks,
                createdAt: project.createdAt
            )
            
            var newEmployeeTasks = employee.tasks
            newEmployeeTasks.append(task.id)
            let newEmployee = Employee(
                id: employee.id,
                firstName: employee.firstName,
                lastName: employee.lastName,
                surName: employee.surName,
                position: employee.position,
                tasks: newEmployeeTasks,
                createdAt: employee.createdAt
            )
            
            projects[project.id] = newProject
            employees[employee.id] = newEmployee
            tasks[task.id] = task
        }
    }
}
