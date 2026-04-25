protocol EditProjectInteractorInputProtocol {
    func createProject(_ project: Project) async throws
    func updateProject(_ project: Project) async throws
}

protocol EditProjectInteractorOutputProtocol: AnyObject {}

final class EditProjectInteractor: EditProjectInteractorInputProtocol {
    weak var output: EditProjectInteractorOutputProtocol?
    
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
