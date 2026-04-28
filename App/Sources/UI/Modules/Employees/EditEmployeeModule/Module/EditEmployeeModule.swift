import UIKit

protocol EditEmployeeModuleInputProtocol {
    func createEmployee()
    func updateEmployee(employee: Employee)
}

protocol EditEmployeeModuleOutputProtocol: AnyObject {
    func didCreateEmployee(_ employee: Employee)
    func didUpdateEmployee(_ employee: Employee)
}

final class EditEmployeeModule: Module {
    private(set) var view: UIViewController
    private(set) var input: EditEmployeeModuleInputProtocol

    private init(view: UIViewController, input: EditEmployeeModuleInputProtocol) {
        self.view = view
        self.input = input
    }
    
    static func build(output: EditEmployeeModuleOutputProtocol? = nil) -> EditEmployeeModule {
        let server = AppDelegate.server
        let settings = AppDelegate.settings
        
        let interactor = EditEmployeeInteractor(server: server, settings: settings)
        let router = EditEmployeeRouter()
        let presenter = EditEmployeePresenter(
            interactor: interactor,
            router: router
        )
        let viewController = EditEmployeeViewController(presenter: presenter)
        
        presenter.output = output
        router.viewController = viewController
        presenter.view = viewController
        
        let module = EditEmployeeModule(view: viewController, input: presenter)
        return module
    }
}
