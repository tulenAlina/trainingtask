import UIKit

protocol ProjectsViewControllerDelegate: AnyObject {
    func didAddProject(_ project: ProjectEntity)
    func didUpdateProject(_ project: ProjectEntity)
}

final class ProjectsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProjectsViewControllerDelegate {
    
    private let server = ServerManager.shared.currentServer
    private var projects: [ProjectEntity] = []
    private let projectTable = UITableView()
    
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
            let project = self?.projects[indexPath.row]
            guard let project else {
                completion(false)
                return
            }
            Task {
                do {
                    try await self?.server.deleteProject(project.id)
                    self?.projects.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self?.projectTable.deleteRows(at: [indexPath], with: .automatic)
                        completion(true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    print("Ошибка удаления")
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
        navigationController?.pushViewController(TasksViewController(), animated: true)
        //TODO: передавать проект
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
        try projects = await server.fetchProjects()
        DispatchQueue.main.async {
            self.projectTable.reloadData()
        }
    }
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadProjects()
            } catch {
                print ("Ошибка загрузки")
            }
        }
    }
    
    @objc private func addTapped() {
        let editVC = EditProjectViewController()
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Проекты"
        projectTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(projectTable)
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
