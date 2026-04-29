import UIKit

protocol EmployeeEditModuleInputProtocol {
    func createEmployee()
    func updateEmployee(employee: Employee)
}

protocol EmployeeEditModuleOutputProtocol: AnyObject {
    func didCreateEmployee(_ employee: Employee)
    func didUpdateEmployee(_ employee: Employee)
}

final class EmployeeEditModule: Module {
    private(set) var view: UIViewController
    private(set) var input: EmployeeEditModuleInputProtocol
    
    private init(view: UIViewController, input: EmployeeEditModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(output: EmployeeEditModuleOutputProtocol? = nil) -> EmployeeEditModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = EmployeeEditInteractor(server: server, settings: settings)
        let router = EmployeeEditRouter()
        let presenter = EmployeeEditPresenter(
            interactor: interactor,
            router: router
        )
        let viewController = EmployeeEditViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        interactor.output = presenter
        
        let module = EmployeeEditModule(view: viewController, input: presenter)
        return module
    }
}
