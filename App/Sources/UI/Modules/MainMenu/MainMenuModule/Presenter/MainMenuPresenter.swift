import Foundation

final class MainMenuPresenter: MainMenuModuleInputProtocol {
    weak var view: MainMenuViewInputProtocol?
    private let interactor: MainMenuInteractorInputProtocol
    private var router: MainMenuRouterInputProtocol
    
    init(interactor: MainMenuInteractorInputProtocol, router: MainMenuRouterInputProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - MainMenuViewOutputProtocol
extension MainMenuPresenter: MainMenuViewOutputProtocol {
    func didTapProjectsButton() {
        router.pushProjectsModule()
    }
    
    func didTapTasksButton() {
        router.pushTasksModule()
    }
    
    func didTapEmployeesButton() {
        router.pushEmployeesModule()
    }
    
    func didTapSettingsButton() {
        router.pushSettingsModule()
    }
}
