import Foundation

class StubServer: Server {
    
    enum Errors: Error {
        case itemNotFound
    }
    
    init() {
        setupMockData()
    }
    
    // MARK: - Private properties
    private let sleeepTimeInNanoseconds: UInt64 = 1_000_000_000
    private var projects: [UUID:ProjectEntity] = [:]
    private var employees: [UUID:EmployeeEntity] = [:]
    private var tasks: [UUID:TaskEntity] = [:]
    
    private func setupMockData() {
        for i in 0..<10 {
            var proj = ProjectEntity(projectName: "Project\(i)", description: "Description\(i)")
            var emp = EmployeeEntity(firstName: "Name\(i)", lastName: "LastName\(i)", surName: "Surname\(i)", position: "Position\(i)")
            let task = TaskEntity(taskName: "Task\(i)", projectID: proj.id, workTime: 5, startDate: Date(), endDate: Date(), status: .notStarted, employeeID: emp.id)
            
            proj.tasks.append(task.id)
            emp.tasks.append(task.id)
            
            projects[proj.id] = proj
            employees[emp.id] = emp
            tasks[task.id] = task
        }
    }
    
    // MARK: - Projects
    func fetchProjects() async throws -> [ProjectEntity] {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        var result = Array(projects.values)
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    
    func createProject(_ project: ProjectEntity) async throws -> ProjectEntity {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        projects[project.id] = project
        return project
    }
    
    func updateProject(_ project: ProjectEntity) async throws -> ProjectEntity {
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
            if let task = tasks[taskID], let employeeID = task.employeeID, var employee = employees[employeeID] {
                employee.tasks.removeAll {$0 == task.id}
                employees[employee.id] = employee
            }
            tasks[taskID] = nil
        }
        projects[id] = nil
    }
    
    // MARK: - Employees
    func fetchEmployees() async throws -> [EmployeeEntity] {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        var result = Array(employees.values)
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    func createEmployee(_ employee: EmployeeEntity) async throws -> EmployeeEntity {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        employees[employee.id] = employee
        return employee
    }
    func updateEmployee(_ employee: EmployeeEntity) async throws -> EmployeeEntity {
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
            tasks[taskID]?.employeeID = nil
        }
        employees[id] = nil
    }
    
    // MARK: - Tasks
    func fetchTasks(projectID: UUID?) async throws -> [TaskEntity] {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        var result = Array(tasks.values)
        if let projectID {
            result = result.filter {$0.projectID == projectID}
        }
        result = result.sorted { $0.createdAt > $1.createdAt }
        return result
    }
    func createTask(_ task: TaskEntity) async throws -> TaskEntity {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        tasks[task.id] = task
        
        if var project = projects[task.projectID] {
            project.tasks.append(task.id)
            projects[task.projectID] = project
        }
        
        guard let employeeID = task.employeeID else {return task}
        if var employee = employees[employeeID] {
            employee.tasks.append(task.id)
            employees[employeeID] = employee
        }
        return task
    }
    func updateTask(_ task: TaskEntity) async throws -> TaskEntity {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        guard let oldTask = tasks[task.id] else {
            throw Errors.itemNotFound
        }
        
        if oldTask.projectID != task.projectID {
            if var oldProject = projects[oldTask.projectID] {
                oldProject.tasks.removeAll {$0 == task.id}
                projects[oldTask.projectID] = oldProject
            }
            
            if var newProject = projects[task.projectID]
            {
                newProject.tasks.append(task.id)
                projects[task.projectID] = newProject
            }
        }
        
        if oldTask.employeeID != task.employeeID {
            if let oldEmployeeID = oldTask.employeeID, var oldEmployee = employees[oldEmployeeID] {
                oldEmployee.tasks.removeAll {$0 == task.id}
                employees[oldEmployeeID] = oldEmployee
            }
            
            if let newEmployeeID = task.employeeID, var newEmployee = employees[newEmployeeID]
            {
                newEmployee.tasks.append(task.id)
                employees[newEmployeeID] = newEmployee
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
            project.tasks.removeAll {$0 == task.id}
            projects[task.projectID] = project
        }
        
        if let employeeID = task.employeeID, var employee = employees[employeeID] {
            employee.tasks.removeAll {$0 == task.id}
            employees[employeeID] = employee
        }
        
        tasks[id] = nil
    }
}
