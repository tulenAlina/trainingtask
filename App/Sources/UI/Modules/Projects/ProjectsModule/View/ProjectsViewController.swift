import UIKit

protocol ProjectsViewInputProtocol: AnyObject {
    func setupNavigationBar()
    func setupNavigationTitle()
    func updateUI()
    func setItems(_ newItems: [Project])
    func getItem(at index: Int) -> Project
    func addItem(_ item: Project)
    func updateItem(_ item: Project, where condition: (Project) -> Bool)
    func deleteItem(at index: Int)
    func firstIndex(where predicate: (Project) -> Bool) -> Int?
    func startLoading()
    func stopLoading()
    func endRefreshing()
    func showAlert(_ message: String)
}

protocol ProjectsViewOutputProtocol {
    func viewDidLoad()
    func didRefreshData()
    func didTapProjectRow(project: Project)
    func didTapAddButton()
}

final class ProjectsViewController: BaseListViewController<Project>, ProjectsViewInputProtocol {
    var output: ProjectsViewOutputProtocol
    
    override var emptyStateText: String {
        Localized.noProjects
    }
    
    init(presenter: ProjectsViewOutputProtocol) {
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
    
    func setupNavigationTitle() {
        setupNavigationBar(navigationTitle: Localized.projects)
    }
    
    func setupNavigationBar() {
        setupNavigationBar(navigationTitle: Localized.projects, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddProject))
    }
}

// MARK: - UITableViewDataSource

extension ProjectsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        let project = getItem(at: indexPath.row)
        cell.textLabel?.text = project.projectName
        cell.detailTextLabel?.text = project.description
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProjectsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = getItem(at: indexPath.row)
        output.didTapProjectRow(project: project)
    }
}

// MARK: - Private

private extension ProjectsViewController {
    func setupView() {
        setupTableView()
    }

    func loadData() {
        startLoading()
        refreshData()
    }

    @objc func actionAddProject() {
        output.didTapAddButton()
    }
}
