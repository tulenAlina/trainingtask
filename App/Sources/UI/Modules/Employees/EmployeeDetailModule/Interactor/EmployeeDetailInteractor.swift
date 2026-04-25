protocol EmployeeDetailInteractorInputProtocol {}

protocol EmployeeDetailInteractorOutputProtocol: AnyObject {}

final class EmployeeDetailInteractor: EmployeeDetailInteractorInputProtocol {
    weak var output: EmployeeDetailInteractorOutputProtocol?
}
