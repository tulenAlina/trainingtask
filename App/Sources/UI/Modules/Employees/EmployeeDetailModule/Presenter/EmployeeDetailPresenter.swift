import Foundation

final class EmployeeDetailPresenter: EmployeeDetailModuleInputProtocol {
    weak var view: EmployeeDetailViewInputProtocol?
    weak var output: EmployeeDetailModuleOutputProtocol?
    private let interactor: EmployeeDetailInteractorInputProtocol
    private var router: EmployeeDetailRouterInputProtocol
    
    private var employee: Employee
    
    init(interactor: EmployeeDetailInteractorInputProtocol, router: EmployeeDetailRouterInputProtocol, employee: Employee) {
        self.interactor = interactor
        self.router = router
        self.employee = employee
    }
}

// MARK: - EditEmployeeModuleOutputProtocol
extension EmployeeDetailPresenter: EditEmployeeModuleOutputProtocol {
    func didUpdateEmployee(_ employee: Employee) {
        self.employee = employee
        
        view?.configureLabels(
            fio: employee.fullName,
            position: employee.position
        )
        output?.didUpdateEmployee(employee)
    }
    
    func didCreateEmployee(_ employee: Employee) {}
}

// MARK: - EmployeeDetailViewOutputProtocol
extension EmployeeDetailPresenter: EmployeeDetailViewOutputProtocol {
    func viewDidLoad() {
        view?.configureLabels(
            fio: employee.fullName,
            position: employee.position
        )
    }
    
    func didTapChangeButton() {
        router.pushEditModule(employee: employee, output: self)
    }
    
    func didTapDeleteButton() {
        output?.didDeleteEmployee(employee.id)
        router.close()
    }
}
