import UIKit

final class ProjectsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
            //TODO: удалить
            completion(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Изменить") {[weak self] _,_,completion in
                let project = self?.projects[indexPath.row]
                //TODO: переход на экран редактирования
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let project = projects[indexPath.row]
        //TODO: переход на экран задач по проекту
    }
    
    private func loadProjects() async throws {
        let server = ServerManager.shared.currentServer
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
        //TODO: переход на экран редактирования
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Проекты"
        projectTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(projectTable)
        NSLayoutConstraint.activate([
            projectTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            projectTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            projectTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            projectTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        projectTable.dataSource = self
        projectTable.delegate = self
        refreshView()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshView))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [refreshButton, addButton]
    }
}
