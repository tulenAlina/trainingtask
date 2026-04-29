import UIKit

protocol EmployeeDetailModuleInputProtocol {}

protocol EmployeeDetailModuleOutputProtocol: AnyObject {
    func didUpdateEmployee(_ employee: Employee)
    func didDeleteEmployee(_ employeeID: UUID)
}

final class EmployeeDetailModule: Module {
    private(set) var view: UIViewController
    private(set) var input: EmployeeDetailModuleInputProtocol
    
    private init(view: UIViewController, input: EmployeeDetailModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(employee: Employee, output: EmployeeDetailModuleOutputProtocol?) -> EmployeeDetailModule {
        let interactor = EmployeeDetailInteractor()
        let router = EmployeeDetailRouter()
        let presenter = EmployeeDetailPresenter(
            interactor: interactor,
            router: router,
            employee: employee
        )
        let viewController = EmployeeDetailViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        
        let module = EmployeeDetailModule(view: viewController, input: presenter)
        return module
    }
}
