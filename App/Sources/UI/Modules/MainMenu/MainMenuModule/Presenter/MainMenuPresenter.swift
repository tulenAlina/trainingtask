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
        router.openProjects()
    }
    
    func didTapTasksButton() {
        router.openTasks()
    }
    
    func didTapEmployeesButton() {
        router.openEmployees()
    }
    
    func didTapSettingsButton() {
        router.openSettings()
    }
}
