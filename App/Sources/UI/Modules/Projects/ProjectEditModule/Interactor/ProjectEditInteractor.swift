protocol ProjectEditInteractorInputProtocol {
    func createProject(_ project: Project) async throws
    func updateProject(_ project: Project) async throws
}

protocol ProjectEditInteractorOutputProtocol: AnyObject {}

final class ProjectEditInteractor: ProjectEditInteractorInputProtocol {
    weak var output: ProjectEditInteractorOutputProtocol?
    
    private let server: Server
    private let settings: SettingsManager
    
    init(server: Server, settings: SettingsManager) {
        self.server = server
        self.settings = settings
    }
    
    func createProject(_ project: Project) async throws {
        try await server.createProject(project)
    }
    
    func updateProject(_ project: Project) async throws {
        try await server.updateProject(project)
    }
}
