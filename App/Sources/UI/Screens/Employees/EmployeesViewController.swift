import UIKit

final class EmployeesViewController: BaseListViewController<Employee> {
    enum EmployeesDisplayMode {
        case list
        case selection(onSelect: (Employee) -> Void)
    }
    
    private let server: Server = AppDelegate.server
    private let mode: EmployeesDisplayMode
    
    override var emptyStateText: String {
        return Localized.noEmployees
    }
    
    init(mode: EmployeesDisplayMode = .list) {
        self.mode = mode
        super.init(settings: AppDelegate.settings)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
    }
    
    @objc override func refreshData() {
        Task {
            do {
                try await loadEmployees()
                await MainActor.run {
                    updateUI()
                }
            } catch {
                await MainActor.run {
                    endRefreshing()
                    showAlert(Localized.loadFailed)
                }
            }
        }
    }
}

extension EmployeesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "EmployeeCell")
        let employee = getItem(at: indexPath.row)
        cell.textLabel?.text = employee.fullName
        cell.detailTextLabel?.text = employee.position
        
        return cell
    }
}

extension EmployeesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let employee = getItem(at: indexPath.row)
        switch mode {
        case .list:
            let detailViewController = EmployeeDetailViewController(indexPath: indexPath, employee: employee, server: server, onUpdate: { [weak self] employee in
                self?.updateItem(employee) { $0.id == employee.id }
            }, onDelete: { [weak self] indexPath in
                self?.deleteEmployee(at: indexPath)
            })
            navigationController?.pushViewController(detailViewController, animated: true)
        case .selection(let onSelect):
            onSelect(employee)
            navigationController?.popViewController(animated: true)
        }
    }
}

private extension EmployeesViewController {
    func setupView() {
        setupNavigationBar()
        setupTableView()
    }
    
    func setupNavigationBar() {
        switch mode {
        case .list:
            super.setupNavigationBar(navigationTitle: Localized.employees, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddEmployee))
        case .selection:
            super.setupNavigationBar(navigationTitle: Localized.employees)
        }
    }
    
    func loadEmployees() async throws{
        let items = try await server.fetchEmployees()
        setItems(items)
    }
    
    func loadData() {
        startLoading()
        refreshData()
    }
    
    func deleteEmployee(at indexPath: IndexPath) {
        startLoading()
        let employee = getItem(at: indexPath.row)

        Task {
            do {
                try await server.deleteEmployee(employee.id)
                await MainActor.run {
                    deleteItem(at: indexPath.row)
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
    
    @objc func actionAddEmployee() {
        let editViewController = EditEmployeeViewController(server: server, action: .create( { [weak self] employee in
            self?.addItem(employee)
        }))
        navigationController?.pushViewController(editViewController, animated: true)
    }
}
