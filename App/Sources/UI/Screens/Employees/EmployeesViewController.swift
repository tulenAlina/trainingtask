import UIKit

protocol EmployeesViewControllerDelegate: AnyObject {
    func didAddEmployee(_ employee: Employee)
    func didUpdateEmployee(_ employee: Employee)
}

extension EmployeesViewControllerDelegate {
    func didAddEmployee(_ employee: Employee) {}
}

final class EmployeesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EmployeesViewControllerDelegate {
    
    enum Mode {
        case normal
        case selection(completion: (Employee) -> Void)
    }
    
    private let mode: Mode
    private let employeeTable = UITableView()
    private let server = ServerManager.shared.currentServer
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    private var employees: [Employee] = []
    
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
    
    func didAddEmployee(_ employee: Employee) {
        let maxRecords = SettingsManager.shared.maxRecords
        if employees.count >= maxRecords {
            employees.removeLast()
            employeeTable.deleteRows(at: [IndexPath(row: maxRecords - 1, section: 0)], with: .automatic)
        }
        employees.insert(employee, at: 0)
        employeeTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        updateEmptyState()
    }
    
    func didUpdateEmployee(_ employee: Employee) {
        if let index = employees.firstIndex(where: {$0.id == employee.id}) {
            employees[index] = employee
            employeeTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "EmployeeCell")
        cell.textLabel?.text = employees[indexPath.row].fullName
        cell.detailTextLabel?.text = employees[indexPath.row].position
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        switch mode {
        case .normal:
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {[weak self] _, _, completion in
                self?.loadingIndicator.startAnimating()
                self?.view.isUserInteractionEnabled = false
                let employee = self?.employees[indexPath.row]
                guard let employee else {
                    completion(false)
                    return
                }
                Task {
                    do {
                        try await self?.server.deleteEmployee(employee.id)
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
                        self?.showAlert("Не удалось удалить сотрудника")
                    }
                }
            }
            
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
            let detailViewController = EmployeeDetailViewController(employee: employee)
            detailViewController.delegate = self
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection(let completion):
            completion(employee)
            navigationController?.popViewController(animated: true)
        }
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
        employeeTable.dataSource = self
        employeeTable.delegate = self
        employeeTable.translatesAutoresizingMaskIntoConstraints = false
        employeeTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        view.addSubview(employeeTable)
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
            employeeTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            employeeTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            employeeTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            employeeTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        employees = Array(allEmployees.prefix(SettingsManager.shared.maxRecords))
        DispatchQueue.main.async {
            self.employeeTable.reloadData()
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
            employeeTable.backgroundView = label
        } else {
            employeeTable.backgroundView = nil
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
        let editVC = EditEmployeeViewController()
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
}
