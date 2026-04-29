protocol EmployeeEditInteractorInputProtocol {
    func createEmployee(_ employee: Employee) async throws
    func updateEmployee(_ employee: Employee) async throws
}

protocol EmployeeEditInteractorOutputProtocol: AnyObject {}

final class EmployeeEditInteractor: EmployeeEditInteractorInputProtocol {
    weak var output: EmployeeEditInteractorOutputProtocol?
    
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
