import Foundation

protocol TasksInteractorInputProtocol {
    func loadData(projectID: UUID?) async throws -> (tasks: [ProjectTask], projects: [Project]?, employees: [Employee])
    func deleteTask(_ taskID: UUID) async throws
}

protocol TasksInteractorOutputProtocol: AnyObject {}

final class TasksInteractor: TasksInteractorInputProtocol {
    weak var output: TasksInteractorOutputProtocol?
    
    private let server: Server
    private let settings: SettingsManager
    
    init(server: Server, settings: SettingsManager) {
        self.server = server
        self.settings = settings
    }
    
    func loadData(projectID: UUID?) async throws -> (tasks: [ProjectTask], projects: [Project]?, employees: [Employee])  {
        async let allTasks = try await server.loadTasks(projectID: projectID)
        async let allEmployees = server.loadEmployees()
        if projectID == nil {
            async let allProjects = server.loadProjects()
            return try await (allTasks, allProjects, allEmployees)
        } else {
            return try await (allTasks, nil, allEmployees)
        }
    }
    
    func deleteTask(_ taskID: UUID) async throws {
        try await server.deleteTask(taskID)
    }
}
