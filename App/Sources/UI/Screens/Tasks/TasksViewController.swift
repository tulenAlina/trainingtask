import UIKit

protocol TasksViewControllerDelegate: AnyObject {
    func didAddTask(_ task: TaskEntity)
    func didUpdateTask(_ task: TaskEntity)
}


final class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TasksViewControllerDelegate {
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
                    self?.refreshView()
                    DispatchQueue.main.async {
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
            let task = self?.tasks[indexPath.row]
            guard let task else {
                completion(false)
                return
            }
            let editVC: EditTaskViewController
            if let project = self?.project {
                editVC = EditTaskViewController(task, project: project)
            } else {
                editVC = EditTaskViewController(task)
            }
            editVC.delegate = self
            self?.navigationController?.pushViewController(editVC, animated: true)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func didAddTask(_ task: TaskEntity) {
        tasks.append(task)
        taskTable.insertRows(at: [IndexPath(row: tasks.count-1, section: 0)], with: .automatic)
    }
    
    func didUpdateTask(_ task: TaskEntity) {
        if let index = tasks.firstIndex(where: {$0.id == task.id}) {
            tasks[index] = task
            taskTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func loadTasks() async throws {
        let allTasks = try await server.fetchTasks(projectID: project?.id)
        tasks = Array(allTasks.prefix(SettingsManager.shared.maxRecords))
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
        if tasks.count >= SettingsManager.shared.maxRecords {
            showAlert("Достигнуто максимальное количество задач (\(SettingsManager.shared.maxRecords))")
            return
        }
        
        let editVC: EditTaskViewController
        if let project {
            editVC = EditTaskViewController(project: project)
        } else {
            editVC = EditTaskViewController()
        }
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func showAlert (_ message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
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
