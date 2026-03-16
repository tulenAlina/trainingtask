import UIKit

final class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let project: ProjectEntity?
    private let server = ServerManager.shared.currentServer
    private var tasks: [TaskEntity] = []
    private let taskTable = UITableView()
    
    init() {
            self.project = nil
            super.init(nibName: nil, bundle: nil)
        }
        
        init(project: ProjectEntity) {
            self.project = project
            super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "TaskCell")
        cell.textLabel?.text = tasks[indexPath.row].taskName
        cell.detailTextLabel?.text = project?.projectName
        let task = tasks[indexPath.row]
        switch task.status {
        case .notStarted:
            cell.imageView?.image = UIImage(systemName: "circle")
        case .inProgress:
            cell.imageView?.image = UIImage(systemName: "play.circle")
        case .completed:
            cell.imageView?.image = UIImage(systemName: "checkmark.circle")
        case .postponed:
            cell.imageView?.image = UIImage(systemName: "pause.circle")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] _,_,completion in
            let task = self?.tasks[indexPath.row]
            guard let task else {
                completion(false)
                return
            }
            Task {
                do {
                    try await self?.server.deleteTask(task.id)
                    self?.tasks.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self?.taskTable.deleteRows(at: [indexPath], with: .automatic)
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
//            let task = self?.tasks[indexPath.row]
//            guard let task else {
//                completion(false)
//                return
//            }
//            let editVC = EditTaskViewController(project)
//            editVC.delegate = self
//            self?.navigationController?.pushViewController(editVC, animated: true)
//            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func loadTasks() async throws {
        try tasks = await server.fetchTasks(projectID: project?.id)
        DispatchQueue.main.async {
            self.taskTable.reloadData()
        }
    }
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadTasks()
            } catch {
                print ("Ошибка загрузки")
            }
        }
    }
    
    @objc private func addTapped() {
        //TODO: переход на экран редактирования задач
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Задачи"
        taskTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskTable)
        NSLayoutConstraint.activate([
            taskTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            taskTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            taskTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        taskTable.dataSource = self
        taskTable.delegate = self
        refreshView()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshView))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [refreshButton, addButton]
    }
}
