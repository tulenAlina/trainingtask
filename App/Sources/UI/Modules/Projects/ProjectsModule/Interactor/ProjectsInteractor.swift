import Foundation

protocol ProjectsInteractorInputProtocol {
    func loadProjects() async throws -> [Project]
    func deleteProject(_ projectID: UUID) async throws
}

protocol ProjectsInteractorOutputProtocol: AnyObject {}

final class ProjectsInteractor: ProjectsInteractorInputProtocol {
    weak var output: ProjectsInteractorOutputProtocol?
    
    private let server: Server
    private let settings: SettingsManager
    
    init(server: Server, settings: SettingsManager) {
        self.server = server
        self.settings = settings
    }
    
    func loadProjects() async throws -> [Project] {
        return try await server.loadProjects()
    }
    
    func deleteProject(_ projectID: UUID) async throws {
        try await server.deleteProject(projectID)
    }
}
