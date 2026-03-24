import UIKit

protocol ProjectsViewControllerDelegate: AnyObject {
    func didAddProject(_ project: Project)
    func didUpdateProject(_ project: Project)
}

final class ProjectsViewController: UIViewController {
    
    enum Mode {
        case normal
        case selection(completion: (Project) -> Void)
    }
    
    private let mode: Mode
    private let server = ServerManager.shared.currentServer
    private var projects: [Project] = []
    private let projectTable = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    init(mode: Mode = .normal) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Проекты"
        setupTableView()
        setupNavigationBar()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupTableView() {
        projectTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(projectTable)
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        projectTable.dataSource = self
        projectTable.delegate = self
        projectTable.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            projectTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            projectTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            projectTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            projectTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        switch mode {
        case .normal:
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            navigationItem.rightBarButtonItem = addButton
        case .selection:
            break
        }
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func loadProjects() async throws {
        let allProjects = try await server.fetchProjects()
        projects = Array(allProjects.prefix(SettingsManager.shared.maxRecords))
        DispatchQueue.main.async {
            self.projectTable.reloadData()
            self.updateEmptyState()
            self.loadingIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func updateEmptyState() {
        if projects.isEmpty {
            let label = UILabel()
            label.text = "Нет проектов"
            label.textAlignment = .center
            label.textColor = .gray
            projectTable.backgroundView = label
        } else {
            projectTable.backgroundView = nil
        }
    }
    
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadProjects()
                await MainActor.run {
                    refreshControl.endRefreshing()
                }
            } catch {
                await MainActor.run {
                    refreshControl.endRefreshing()
                    showAlert("Не удалось загрузить проекты")
                }
            }
        }
    }
    
    @objc private func addTapped() {
        let editVC = EditProjectViewController()
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
}

extension ProjectsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        cell.textLabel?.text = projects[indexPath.row].projectName
        cell.detailTextLabel?.text = projects[indexPath.row].description
        return cell
    }
}

extension ProjectsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        switch mode {
        case .normal:
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] _,_,completion in
                self?.loadingIndicator.startAnimating()
                self?.view.isUserInteractionEnabled = false
                let project = self?.projects[indexPath.row]
                guard let project else {
                    completion(false)
                    return
                }
                Task {
                    do {
                        try await self?.server.deleteProject(project.id)
                        self?.refreshView()
                        DispatchQueue.main.async {
                            completion(true)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self?.loadingIndicator.stopAnimating()
                            self?.view.isUserInteractionEnabled = true
                            completion(false)
                        }
                        self?.showAlert("Не удалось удалить проект")
                    }
                }
            }
            
            let editAction = UIContextualAction(style: .normal, title: "Изменить") {[weak self] _,_,completion in
                let project = self?.projects[indexPath.row]
                guard let project else {
                    completion(false)
                    return
                }
                let editVC = EditProjectViewController(project)
                editVC.delegate = self
                self?.navigationController?.pushViewController(editVC, animated: true)
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        case .selection:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = projects[indexPath.row]
        
        switch mode {
        case .normal:
            let tasksViewConttroller = TasksViewController(project: project)
            navigationController?.pushViewController(tasksViewConttroller, animated: true)
        case .selection(let completion):
            completion(project)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension ProjectsViewController: ProjectsViewControllerDelegate {
    func didAddProject(_ project: Project) {
        let maxRecords = SettingsManager.shared.maxRecords
        if projects.count >= maxRecords {
            projects.removeLast()
            projectTable.deleteRows(at: [IndexPath(row: maxRecords - 1, section: 0)], with: .automatic)
        }
        projects.insert(project, at: 0)
        projectTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        updateEmptyState()
    }
    
    func didUpdateProject(_ project: Project) {
        if let index = projects.firstIndex(where: {$0.id == project.id}) {
            projects[index] = project
            projectTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
}
