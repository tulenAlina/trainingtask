import UIKit

protocol EmployeesViewInputProtocol: AnyObject {
    func setupNavigationTitle()
    func setupNavigationBar()
    func updateUI()
    func setItems(_ newItems: [Employee])
    func getItem(at index: Int) -> Employee
    func addItem(_ item: Employee)
    func updateItem(_ item: Employee, where condition: (Employee) -> Bool)
    func deleteItem(at index: Int)
    func firstIndex(where predicate: (Employee) -> Bool) -> Int?
    func startLoading()
    func stopLoading()
    func endRefreshing()
    func showAlert(_ message: String)
}

protocol EmployeesViewOutputProtocol {
    func viewDidLoad()
    func didRefreshData()
    func didTapEmployeeRow(employee: Employee)
    func didTapAddButton()
}

final class EmployeesViewController: BaseListViewController<Employee>, EmployeesViewInputProtocol {
    var output: EmployeesViewOutputProtocol
    
    override var emptyStateText: String {
        Localized.noEmployees
    }
    
    init(presenter: EmployeesViewOutputProtocol) {
        output = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        output.viewDidLoad()
    }
    
    @objc override func refreshData() {
        output.didRefreshData()
    }
    
    func setupNavigationTitle() {
        setupNavigationBar(navigationTitle: Localized.employees)
    }
    
    func setupNavigationBar() {
        setupNavigationBar(navigationTitle: Localized.employees, rightButtonSystemItem: .add, rightButtonAction: #selector(actionAddEmployee))
    }
}

// MARK: - UITableViewDataSource
extension EmployeesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedItemsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "EmployeeCell")
        let employee = getItem(at: indexPath.row)
        cell.textLabel?.text = employee.fullName
        cell.detailTextLabel?.text = employee.position
        return cell
    }
}

// MARK: - UITableViewDelegate
extension EmployeesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let employee = getItem(at: indexPath.row)
        output.didTapEmployeeRow(employee: employee)
    }
}

// MARK: - Private
private extension EmployeesViewController {
    func setupView() {
        setupTableView()
    }

    func loadData() {
        startLoading()
        refreshData()
    }

    @objc func actionAddEmployee() {
        output.didTapAddButton()
    }
}
