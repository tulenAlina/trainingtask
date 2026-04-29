protocol TaskEditInteractorInputProtocol {
    func loadData() async throws -> (projects: [Project], employees: [Employee])
    func createTask(_ task: ProjectTask) async throws
    func updateTask(_ task: ProjectTask) async throws
    func defaultDaysBetween() -> Int
}

protocol TaskEditInteractorOutputProtocol: AnyObject {}

final class TaskEditInteractor: TaskEditInteractorInputProtocol {
    weak var output: TaskEditInteractorOutputProtocol?
    
    private let server: Server
    private let settings: SettingsManager
    
    init(server: Server, settings: SettingsManager) {
        self.server = server
        self.settings = settings
    }
    
    func loadData() async throws -> (projects: [Project], employees: [Employee]) {
        async let projects = server.loadProjects()
        async let employees = server.loadEmployees()
        return try await (projects, employees)
    }
    
    func createTask(_ task: ProjectTask) async throws {
        try await server.createTask(task)
    }
    
    func updateTask(_ task: ProjectTask) async throws {
        try await server.updateTask(task)
    }
    
    func defaultDaysBetween() -> Int {
        settings.defaultDaysBetween
    }
}
