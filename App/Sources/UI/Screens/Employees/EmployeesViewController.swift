import UIKit

protocol EmployeesViewControllerDelegate: AnyObject {
    func didAddEmployee(_ employee: Employee)
    func didUpdateEmployee(_ employee: Employee)
}

extension EmployeesViewControllerDelegate {
    func didAddEmployee(_ employee: Employee) {}
}

final class EmployeesViewController: UIViewController {
    
    enum Mode {
        case normal
        case selection(completion: (Employee) -> Void)
    }
    
    private let server: Server
    private let settings: SettingsManager
    private let mode: Mode
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    private var employees: [Employee] = []
    
    init(mode: Mode = .normal, server: Server, settings: SettingsManager) {
        self.mode = mode
        self.server = server
        self.settings = settings
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
        title = "Сотрудники"
        setupTableView()
        setupNavigationBar()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        view.addSubview(tableView)
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
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func loadEmployees() async throws{
        let allEmployees = try await server.fetchEmployees()
        employees = Array(allEmployees.prefix(settings.maxRecords))
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateEmptyState()
            self.loadingIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    private func updateEmptyState() {
        if employees.isEmpty {
            let label = UILabel()
            label.text = "Нет сотрудников"
            label.textAlignment = .center
            label.textColor = .gray
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func performDelete(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        self.loadingIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let employee = self.employees[indexPath.row]

        Task {
            do {
                try await self.server.deleteEmployee(employee.id)
                self.refreshView()
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    completion(false)
                }
                self.showAlert("Не удалось удалить сотрудника")
            }
        }
    }
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadEmployees()
                await MainActor.run {
                    refreshControl.endRefreshing()
                }
            } catch {
                await MainActor.run {
                    refreshControl.endRefreshing()
                    showAlert("Не удалось загрузить сотрудников")
                }
            }
        }
    }
    
    @objc private func addTapped() {
        let editVC = EditEmployeeViewController(server: server)
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
}

extension EmployeesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "EmployeeCell")
        cell.textLabel?.text = employees[indexPath.row].fullName
        cell.detailTextLabel?.text = employees[indexPath.row].position
        return cell
    }
}

extension EmployeesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        switch mode {
        case .normal:
            let deleteAction = createDeleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [deleteAction])
        case .selection:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let employee = employees[indexPath.row]
        switch mode {
        case .normal:
            let detailViewController = EmployeeDetailViewController(employee: employee, server: server)
            detailViewController.delegate = self
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection(let completion):
            completion(employee)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func createDeleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] _,_,completion in
            self?.performDelete(at: indexPath, completion: completion)
        }
        return deleteAction
    }
}

extension EmployeesViewController: EmployeesViewControllerDelegate {
    private var lastRowIndexWithinLimit: Int {
        return settings.maxRecords - 1
    }

    private var lastIndexPathWithinLimit: IndexPath {
        return IndexPath(row: lastRowIndexWithinLimit, section: 0)
    }

    private var firstIndexPath: IndexPath {
        return IndexPath(row: 0, section: 0)
    }
    
    func didAddEmployee(_ employee: Employee) {
        let maxRecords = settings.maxRecords
        if employees.count >= maxRecords {
            employees.removeLast()
            tableView.deleteRows(at: [lastIndexPathWithinLimit], with: .automatic)
        }
        employees.insert(employee, at: 0)
        tableView.insertRows(at: [firstIndexPath], with: .automatic)
        updateEmptyState()
    }
    
    func didUpdateEmployee(_ employee: Employee) {
        if let index = employees.firstIndex(where: {$0.id == employee.id}) {
            employees[index] = employee
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
