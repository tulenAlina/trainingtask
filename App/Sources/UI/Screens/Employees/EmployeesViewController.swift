import UIKit

protocol EmployeesViewControllerDelegate: AnyObject {
    func didAddEmployee(_ employee: EmployeeEntity)
    func didUpdateEmployee(_ employee: EmployeeEntity)
}

final class EmployeesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EmployeesViewControllerDelegate {
    
    private var employees: [EmployeeEntity] = []
    private let employeeTable = UITableView()
    private let server = ServerManager.shared.currentServer
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "EmployeeCell")
        cell.textLabel?.text = "\(employees[indexPath.row].firstName) \(employees[indexPath.row].lastName) \(employees[indexPath.row].surName ?? "")"
        cell.detailTextLabel?.text = employees[indexPath.row].position
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
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
                    self?.employees.remove(at: indexPath.row)
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
        let editAction = UIContextualAction(style: .normal, title: "Изменить") {[weak self] _, _, completion in
            let employee = self?.employees[indexPath.row]
            guard let employee else {
                completion(false)
                return
            }
            let editVC = EditEmployeeViewController(employee)
            editVC.delegate = self
            self?.navigationController?.pushViewController(editVC, animated: true)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func loadEmployees() async throws{
        let allEmployees = try await server.fetchEmployees()
        employees = Array(allEmployees.prefix(SettingsManager.shared.maxRecords))
        DispatchQueue.main.async {
            self.employeeTable.reloadData()
            self.loadingIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadEmployees()
            } catch {
                showAlert("Не удалось загрузить сотрудников")
            }
        }
    }
    
    @objc private func addTapped() {
        if employees.count >= SettingsManager.shared.maxRecords {
            showAlert("Достигнуто максимальное количество сотрудников (\(SettingsManager.shared.maxRecords))")
            return
        }
        
        let editVC = EditEmployeeViewController()
        editVC.delegate = self
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func didAddEmployee(_ employee: EmployeeEntity) {
        employees.append(employee)
        employeeTable.insertRows(at: [IndexPath(row: employees.count-1, section: 0)], with: .automatic)
    }
    
    func didUpdateEmployee(_ employee: EmployeeEntity) {
        if let index = employees.firstIndex(where: {$0.id == employee.id}) {
            employees[index] = employee
            employeeTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Сотрудники"
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        
        view.addSubview(employeeTable)
        view.addSubview(loadingIndicator)
        
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            employeeTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            employeeTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            employeeTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            employeeTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        employeeTable.dataSource = self
        employeeTable.delegate = self
        employeeTable.translatesAutoresizingMaskIntoConstraints = false
        
        refreshView()
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshView))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItems = [refreshButton, addButton]
    }
}
