protocol TaskDetailInteractorInputProtocol {}

protocol TaskDetailInteractorOutputProtocol: AnyObject {}

final class TaskDetailInteractor: TaskDetailInteractorInputProtocol {
    weak var output: TaskDetailInteractorOutputProtocol?
}
