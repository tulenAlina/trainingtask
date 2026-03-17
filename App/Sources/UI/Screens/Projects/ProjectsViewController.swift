import UIKit

protocol ProjectsViewControllerDelegate: AnyObject {
    func didAddProject(_ project: ProjectEntity)
    func didUpdateProject(_ project: ProjectEntity)
}

final class ProjectsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProjectsViewControllerDelegate {
    
    private let server = ServerManager.shared.currentServer
    private var projects: [ProjectEntity] = []
    private let projectTable = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ProjectCell")
        cell.textLabel?.text = projects[indexPath.row].projectName
        cell.detailTextLabel?.text = projects[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
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
                    self?.projects.remove(at: indexPath.row)
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = projects[indexPath.row]
        navigationController?.pushViewController(TasksViewController(project: project), animated: true)
    }
    
    func didAddProject(_ project: ProjectEntity) {
        projects.append(project)
        projectTable.insertRows(at: [IndexPath(row: projects.count-1, section: 0)], with: .automatic)
    }
    
    func didUpdateProject(_ project: ProjectEntity) {
        if let index = projects.firstIndex(where: {$0.id == project.id}) {
            projects[index] = project
            projectTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func loadProjects() async throws {
        let allProjects = try await server.fetchProjects()
        projects = Array(allProjects.prefix(SettingsManager.shared.maxRecords))
        DispatchQueue.main.async {
            self.projectTable.reloadData()
            self.loadingIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadProjects()
            } catch {
                showAlert("Не удалось загрузить проекты")
            }
        }
    }
    
    @objc private func addTapped() {
        if projects.count >= SettingsManager.shared.maxRecords {
            showAlert("Достигнуто максимальное количество проектов (\(SettingsManager.shared.maxRecords))")
            return
        }
        
        let editVC = EditProjectViewController()
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Проекты"
        projectTable.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        
        view.addSubview(projectTable)
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            projectTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            projectTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            projectTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            projectTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        projectTable.dataSource = self
        projectTable.delegate = self
        refreshView()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshView))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [refreshButton, addButton]
    }
}
