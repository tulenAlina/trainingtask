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
        return Array(projects.values)
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
        if projects[id] == nil {
            throw Errors.itemNotFound
        }
        projects[id] = nil
    }
    
    // MARK: - Employees
    func fetchEmployees() async throws -> [EmployeeEntity] {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        return Array(employees.values)
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
        if employees[id] == nil {
            throw Errors.itemNotFound
        }
        employees[id] = nil
    }
    
    // MARK: - Tasks
    func fetchTasks(projectID: UUID?) async throws -> [TaskEntity] {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        if let projectID {
            return Array(tasks.values.filter {$0.projectID == projectID})
        }
        return Array(tasks.values)
    }
    func createTask(_ task: TaskEntity) async throws -> TaskEntity {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        tasks[task.id] = task
        return task
    }
    func updateTask(_ task: TaskEntity) async throws -> TaskEntity {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        if tasks[task.id] == nil {
            throw Errors.itemNotFound
        }
        
        tasks[task.id] = task
        return task
    }
    func deleteTask(_ id: UUID) async throws {
        try await Task.sleep(nanoseconds: sleeepTimeInNanoseconds)
        if tasks[id] == nil {
            throw Errors.itemNotFound
        }
        tasks[id] = nil
    }
}
