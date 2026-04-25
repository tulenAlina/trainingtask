protocol EditEmployeeInteractorInputProtocol {
    func createEmployee(_ employee: Employee) async throws
    func updateEmployee(_ employee: Employee) async throws
}

protocol EditEmployeeInteractorOutputProtocol: AnyObject {}

final class EditEmployeeInteractor: EditEmployeeInteractorInputProtocol {
    weak var output: EditEmployeeInteractorOutputProtocol?
    
    private let server: Server
    private let settings: SettingsManager
    
    init(server: Server, settings: SettingsManager) {
        self.server = server
        self.settings = settings
    }
    
    func createEmployee(_ employee: Employee) async throws {
        try await server.createEmployee(employee)
    }
    
    func updateEmployee(_ employee: Employee) async throws {
        try await server.updateEmployee(employee)
    }
}
