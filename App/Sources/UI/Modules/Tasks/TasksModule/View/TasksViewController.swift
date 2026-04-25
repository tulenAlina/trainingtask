import UIKit

protocol TasksViewInputProtocol: AnyObject {
    func updateUI()
    func setItems(_ newItems: [ProjectTask])
    func getItem(at index: Int) -> ProjectTask
    func addItem(_ item: ProjectTask)
    func updateItem(_ item: ProjectTask, where condition: (ProjectTask) -> Bool)
    func deleteItem(at index: Int)
    func firstIndex(where predicate: (ProjectTask) -> Bool) -> Int?
    func startLoading()
    func stopLoading()
    func endRefreshing()
    func showAlert(_ message: String)
}

protocol TasksViewOutputProtocol {
    func viewDidLoad()
    func didRefreshData()
    func didTapTaskRow(task: ProjectTask)
    func didTapAddButton()
    func viewModelForTask(at index: Int) -> TaskCellViewModel?
}

final class TasksViewController: BaseListViewController<ProjectTask>, TasksViewInputProtocol {
    var output: TasksViewOutputProtocol
    
    override var emptyStateText: String {
        Localized.noTasks
    }
    
    init(presenter: TasksViewOutputProtocol) {
        output = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        output.viewDidLoad()
    }
    
    @objc override func refreshData() {
        output.didRefreshData()
    }
}

// MARK: - UITableViewDataSource

extension TasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TaskCell")
        let cellViewModel = output.viewModelForTask(at: indexPath.row)
        cell.textLabel?.text = cellViewModel?.taskName
        cell.detailTextLabel?.text = cellViewModel?.projectName
        
        switch cellViewModel?.status {
        case .notStarted:
            cell.imageView?.image = UIImage(systemName: "circle")
        case .inProgress:
            cell.imageView?.image = UIImage(systemName: "play.circle")
        case .completed:
            cell.imageView?.image = UIImage(systemName: "checkmark.circle")
        case .postponed:
            cell.imageView?.image = UIImage(systemName: "pause.circle")
        default:
            break
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = getItem(at: indexPath.row)
        output.didTapTaskRow(task: task)
    }
}

// MARK: - Private

private extension TasksViewController {
    func setupView() {
        setupNavigationBar(navigationTitle: Localized.tasks, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddTask))
        setupTableView()
    }

    func loadData() {
        startLoading()
        refreshData()
    }

    @objc func actionAddTask() {
        output.didTapAddButton()
    }
}
