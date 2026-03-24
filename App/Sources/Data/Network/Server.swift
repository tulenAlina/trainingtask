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
    
    func fetchTasks(projectID: UUID?) async throws -> [ProjectTask]
    func createTask(_ task: ProjectTask) async throws -> ProjectTask
    func updateTask(_ task: ProjectTask) async throws -> ProjectTask
    func deleteTask(_ id: UUID) async throws
}
