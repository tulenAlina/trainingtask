import Foundation

protocol Server {
    func fetchProjects() async throws -> [Project]
    func createProject(_ project: Project) async throws -> Project
    func updateProject(_ project: Project) async throws -> Project
    func deleteProject(_ id: UUID) async throws
    
    func fetchEmployees() async throws -> [Employee]
    func createEmployee(_ employee: Employee) async throws -> Employee
    func updateEmployee(_ employee: Employee) async throws -> Employee
    func deleteEmployee(_ id: UUID) async throws
    
    func fetchTasks(projectID: UUID?) async throws -> [Task]
    func createTask(_ task: Task) async throws -> Task
    func updateTask(_ task: Task) async throws -> Task
    func deleteTask(_ id: UUID) async throws
}
