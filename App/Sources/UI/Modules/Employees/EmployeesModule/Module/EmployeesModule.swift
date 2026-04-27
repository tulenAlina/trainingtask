import UIKit

protocol EmployeeSelectionOutputProtocol: AnyObject {
    func didSelectEmployee(_ employee: Employee)
}

protocol EmployeesModuleInputProtocol {}

final class EmployeesModule: Module {
    private(set) var view: UIViewController
    private(set) var input: EmployeesModuleInputProtocol

    private init(view: UIViewController, input: EmployeesModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(selectionOutput: EmployeeSelectionOutputProtocol? = nil) -> EmployeesModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = EmployeesInteractor(server: server, settings: settings)
        let router = EmployeesRouter()
        let presenter = EmployeesPresenter(
            interactor: interactor,
            router: router,
            selectionOutput: selectionOutput
        )
        let viewController = EmployeesViewController(presenter: presenter)
        
        router.viewController = viewController
        presenter.view = viewController
        
        let module = EmployeesModule(view: viewController, input: presenter)
        return module
    }
}
