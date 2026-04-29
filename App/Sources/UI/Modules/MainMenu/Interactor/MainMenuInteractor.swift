import Foundation

protocol MainMenuInteractorInputProtocol {}

protocol MainMenuInteractorOutputProtocol: AnyObject {}

final class MainMenuInteractor: MainMenuInteractorInputProtocol {
    weak var output: MainMenuInteractorOutputProtocol?
}
