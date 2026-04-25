import Foundation

protocol EmployeesInteractorInputProtocol {
    func fetchEmployees() async throws -> [Employee]
    func deleteEmployee(_ employeeID: UUID) async throws
}

protocol EmployeesInteractorOutputProtocol: AnyObject {}

final class EmployeesInteractor: EmployeesInteractorInputProtocol {
    weak var output: EmployeesInteractorOutputProtocol?
    
    private let server: Server
    private let settings: SettingsManager
    
    init(server: Server, settings: SettingsManager) {
        self.server = server
        self.settings = settings
    }
    
    func fetchEmployees() async throws -> [Employee] {
        return try await server.fetchEmployees()
    }
    
    func deleteEmployee(_ employeeID: UUID) async throws {
        try await server.deleteEmployee(employeeID)
    }
}
