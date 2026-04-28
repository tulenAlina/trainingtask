import Foundation

final class EmployeesPresenter: EmployeesModuleInputProtocol {
    weak var view: EmployeesViewInputProtocol?
    private let interactor: EmployeesInteractorInputProtocol
    private var router: EmployeesRouterInputProtocol
    
    private let selectionOutput: EmployeeSelectionOutputProtocol?
    
    private var employees: [Employee] = []
    
    init(interactor: EmployeesInteractorInputProtocol, router: EmployeesRouterInputProtocol, selectionOutput: EmployeeSelectionOutputProtocol?) {
        self.interactor = interactor
        self.router = router
        self.selectionOutput = selectionOutput
    }
}

// MARK: - EmployeesViewOutputProtocol
extension EmployeesPresenter: EmployeesViewOutputProtocol {
    func viewDidLoad() {
        if selectionOutput == nil {
            view?.setupNavigationBar()
        } else {
            view?.setupNavigationTitle()
        }
        view?.startLoading()
        refreshData()
    }
    
    func didRefreshData() {
        refreshData()
    }
    
    func didTapEmployeeRow(employee: Employee) {
        if let selectionOutput {
            selectionOutput.didSelectEmployee(employee)
            router.close()
        } else {
            router.pushDetailScreen(for: employee, output: self)
        }
    }
    
    func didTapAddButton() {
        router.pushAddEmployeeScreen(output: self)
    }
}

// MARK: - EditEmployeeModuleOutputProtocol
extension EmployeesPresenter: EditEmployeeModuleOutputProtocol {
    func didCreateEmployee(_ employee: Employee) {
        view?.addItem(employee)
    }
    
    func didUpdateEmployee(_ employee: Employee) {
        view?.updateItem(employee) { $0.id == employee.id }
    }
}

// MARK: - EmployeeDetailModuleOutputProtocol
extension EmployeesPresenter: EmployeeDetailModuleOutputProtocol {
    func didDeleteEmployee(_ employeeID: UUID) {
        deleteEmployee(employeeID)
    }
}

// MARK: - Private
private extension EmployeesPresenter {
    func loadData() async throws {
        employees = try await interactor.fetchEmployees()
        view?.setItems(employees)
    }
    
    func refreshData() {
        Task {
            do {
                try await loadData()
                await MainActor.run {
                    view?.updateUI()
                }
            } catch {
                await MainActor.run {
                    view?.stopLoading()
                    view?.endRefreshing()
                    view?.showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    func deleteEmployee(_ employeeID: UUID) {
        view?.startLoading()
        guard let index = view?.firstIndex(where: { $0.id == employeeID }) else { return }

        Task {
            do {
                try await interactor.deleteEmployee(employeeID)
                await MainActor.run {
                    view?.deleteItem(at: index)
                    view?.updateUI()
                }
            } catch {
                await MainActor.run {
                    view?.stopLoading()
                    view?.showAlert(Localized.deleteFailed)
                }
            }
        }
    }
}
