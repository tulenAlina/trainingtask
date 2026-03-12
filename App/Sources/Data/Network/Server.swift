import Foundation

protocol Server {
    func fetchProjects() async throws -> [ProjectEntity]
    func createProject(_ project: ProjectEntity) async throws -> ProjectEntity
    func updateProject(_ project: ProjectEntity) async throws -> ProjectEntity
    func deleteProject(_ id: UUID) async throws
    
    func fetchEmployees() async throws -> [EmployeeEntity]
    func createEmployee(_ employee: EmployeeEntity) async throws -> EmployeeEntity
    func updateEmployee(_ employee: EmployeeEntity) async throws -> EmployeeEntity
    func deleteEmployee(_ id: UUID) async throws
    
    func fetchTasks(projectID: UUID?) async throws -> [TaskEntity]
    func createTask(_ task: TaskEntity) async throws -> TaskEntity
    func updateTask(_ task: TaskEntity) async throws -> TaskEntity
    func deleteTask(_ id: UUID) async throws
}
