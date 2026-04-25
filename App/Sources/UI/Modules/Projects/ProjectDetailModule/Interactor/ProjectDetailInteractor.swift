protocol ProjectDetailInteractorInputProtocol {}

protocol ProjectDetailInteractorOutputProtocol: AnyObject {}

final class ProjectDetailInteractor: ProjectDetailInteractorInputProtocol {
    weak var output: ProjectDetailInteractorOutputProtocol?
}
