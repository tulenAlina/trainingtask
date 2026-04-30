import Foundation

final class MainMenuPresenter: MainMenuModuleInputProtocol, MainMenuInteractorOutputProtocol {
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
    func didTapButton(item: MenuItem) {
        router.pushModule(item: item)
    }
}
