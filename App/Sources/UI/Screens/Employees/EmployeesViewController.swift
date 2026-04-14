import UIKit

final class EmployeesViewController: BaseListViewController<Employee> {
    enum EmployeesDisplayMode {
        case list
        case selection(onSelect: (Employee) -> Void)
    }
    
    private let server: Server
    private let mode: EmployeesDisplayMode
    
    private var onSelectEmployee: ((Employee) -> Void)? {
        if case .selection(let onSelect) = mode {
            return onSelect
        }
        return nil
    }
    
    override var emptyStateText: String {
        return Localized.noEmployees
    }
    
    init(server: Server, settings: SettingsManager, mode: EmployeesDisplayMode = .list) {
        self.server = server
        self.mode = mode
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
    
    private func setupNavigationBar() {
        switch mode {
        case .list:
            super.setupNavigationBar(navigationTitle: Localized.employees, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddEmployee))
        case .selection:
            super.setupNavigationBar(navigationTitle: Localized.employees)
        }
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupTableView()
        startLoading()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateUI(){
        tableView.reloadData()
        updateEmptyState()
        stopLoading()
        refreshControl.endRefreshing()
    }
    
    private func loadEmployees() async throws{
        allItems = try await server.fetchEmployees()
        displayedItems = Array(allItems.prefix(settings.maxRecords))
    }
    
    private func deleteEmployee(at indexPath: IndexPath) {
        startLoading()
        let employee = displayedItems[indexPath.row]

        Task {
            do {
                try await server.deleteEmployee(employee.id)
                await MainActor.run {
                    allItems.remove(at: indexPath.row)
                    displayedItems = Array(allItems.prefix(settings.maxRecords))
                    updateUI()
                }
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
                await MainActor.run {
                    updateUI()
                }
            } catch {
                await MainActor.run {
                    refreshControl.endRefreshing()
                    showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    @objc private func actionAddEmployee() {
        let editViewController = EditEmployeeViewController(server: server, action: .create( { [weak self] employee in
            self?.addItem(employee)
        }))
        navigationController?.pushViewController(editViewController, animated: true)
    }
}

extension EmployeesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "EmployeeCell")
        cell.textLabel?.text = displayedItems[indexPath.row].fullName
        cell.detailTextLabel?.text = displayedItems[indexPath.row].position
        return cell
    }
}

extension EmployeesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let employee = displayedItems[indexPath.row]
        switch mode {
        case .list:
            let detailViewController = EmployeeDetailViewController(indexPath: indexPath, employee: employee, server: server, onUpdate: { [weak self] employee in
                self?.updateItem(employee) { $0.id == employee.id }
            }, onDelete: { [weak self] indexPath in
                self?.deleteEmployee(at: indexPath)
            })
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection:
            onSelectEmployee?(employee)
            navigationController?.popViewController(animated: true)
        }
    }
}
