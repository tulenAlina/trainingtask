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
    
    let settings: SettingsManager
    let tableView = UITableView()
    
    private let server: Server
    private let mode: Mode
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
        title = Localized.Screen.employees.localized
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
    
    private func performDelete(at indexPath: IndexPath) {
        self.loadingIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let employee = self.employees[indexPath.row]

        Task {
            do {
                try await self.server.deleteEmployee(employee.id)
                self.refreshView()
            } catch {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                }
                self.showAlert(Localized.Error.deleteFailed.localized)
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
                    showAlert(Localized.Error.loadFailed.localized)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let employee = employees[indexPath.row]
        switch mode {
        case .normal:
            let detailViewController = EmployeeDetailViewController(indexPath: indexPath, employee: employee, server: server)
            detailViewController.delegate = self
            detailViewController.deleteDelegate = self
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection(let completion):
            completion(employee)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension EmployeesViewController: ListUpdatable {
    var items: [Employee] {
        get { employees }
        set { employees = newValue }
    }
    
    var emptyStateText: String {
        return Localized.Empty.noEmployees.localized
    }
}

extension EmployeesViewController: EmployeesViewControllerDelegate {
    
    func didAddEmployee(_ employee: Employee) {
        addItem(employee)
    }
    
    func didUpdateEmployee(_ employee: Employee) {
        updateItem(employee) { $0.id == employee.id }
    }
}

extension EmployeesViewController: EmployeeDetailViewControllerDelegate {
    func didDeleteEmployee(_ employee: Employee, at indexPath: IndexPath) {
        performDelete(at: indexPath)
    }
}
