import UIKit

final class EmployeesViewController: BaseListViewController<Employee> {
    enum EmployeesDisplayMode {
        case list
        case selection(completion: (Employee) -> Void)
    }
    
    private let server: Server
    private let mode: EmployeesDisplayMode
    
    override var emptyStateText: String {
        return Localized.noEmployees
    }
    
    init(mode: EmployeesDisplayMode = .list, server: Server, settings: SettingsManager) {
        self.mode = mode
        self.server = server
        super.init(settings: settings)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshData()
    }
    
    private func setupUI() {
        setupNavigationTitle(Localized.employees)
        setupTableView()
        setupConstraints()
        setupNavigationBar()
        startLoading()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        switch mode {
        case .list:
            setupRightBarButton(systemItem: .add, action: #selector(didTapAddButton))
        case .selection:
            break
        }
    }
    
    private func loadEmployees() async throws{
        let allEmployees = try await server.fetchEmployees()
        items = Array(allEmployees.prefix(settings.maxRecords))
        await MainActor.run {
            tableView.reloadData()
            updateEmptyState()
            stopLoading()
            refreshControl.endRefreshing()
        }
    }
    
    private func performDelete(at indexPath: IndexPath) {
        startLoading()
        let employee = items[indexPath.row]

        Task {
            do {
                try await server.deleteEmployee(employee.id)
                refreshData()
            } catch {
                await MainActor.run {
                    stopLoading()
                    showAlert(Localized.deleteFailed)
                }
            }
        }
    }
    
    @objc private func refreshData() {
        Task {
            do {
                try await loadEmployees()
            } catch {
                await MainActor.run {
                    refreshControl.endRefreshing()
                    showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    @objc private func didTapAddButton() {
        let editViewController = EditEmployeeViewController(server: server, createDelegate: self)
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

extension EmployeesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "EmployeeCell")
        cell.textLabel?.text = items[indexPath.row].fullName
        cell.detailTextLabel?.text = items[indexPath.row].position
        return cell
    }
}

extension EmployeesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let employee = items[indexPath.row]
        switch mode {
        case .list:
            let detailViewController = EmployeeDetailViewController(indexPath: indexPath, employee: employee, server: server, updateDelegate: self, deleteDelegate: self)
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection(let completion):
            completion(employee)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension EmployeesViewController: EmployeeUpdateDelegate {
    func didUpdateEmployee(_ employee: Employee) {
        updateItem(employee) { $0.id == employee.id }
    }
}

extension EmployeesViewController: EmployeeCreateDelegate {
    func didCreateEmployee(_ employee: Employee) {
        addItem(employee)
    }
}

extension EmployeesViewController: EmployeeDeleteDelegate {
    func didDeleteEmployee(_ employee: Employee, at indexPath: IndexPath) {
        performDelete(at: indexPath)
    }
}
