protocol EditTaskInteractorInputProtocol {
    func fetchData() async throws -> (projects: [Project], employees: [Employee])
    func createTask(_ task: ProjectTask) async throws -> ProjectTask
    func updateTask(_ task: ProjectTask) async throws -> ProjectTask
    func defaultDaysBetween() -> Int
}

protocol EditTaskInteractorOutputProtocol: AnyObject {}

final class EditTaskInteractor: EditTaskInteractorInputProtocol {
    weak var output: EditTaskInteractorOutputProtocol?
    
    private let server: Server
    private let settings: SettingsManager
    
    init(server: Server, settings: SettingsManager) {
        self.server = server
        self.settings = settings
    }
    
    func fetchData() async throws -> (projects: [Project], employees: [Employee]) {
        async let projects = server.fetchProjects()
        async let employees = server.fetchEmployees()
        
        return try await (projects, employees)
    }
    
    func createTask(_ task: ProjectTask) async throws -> ProjectTask {
        return try await server.createTask(task)
    }
    
    func updateTask(_ task: ProjectTask) async throws -> ProjectTask {
        return try await server.updateTask(task)
    }
    
    func defaultDaysBetween() -> Int {
        return settings.defaultDaysBetween
    }
}
