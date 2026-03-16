import UIKit

final class EmployeesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var employees: [EmployeeEntity] = []
    private let employeeTable = UITableView()
    private let server = ServerManager.shared.currentServer
    
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
            let employee = self?.employees[indexPath.row]
            guard let employee else {
                completion(false)
                return
            }
            Task {
                do {
                    try await self?.server.deleteEmployee(employee.id)
                    self?.employees.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self?.employeeTable.deleteRows(at: [indexPath], with: .automatic)
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
        let editAction = UIContextualAction(style: .normal, title: "Изменить") {_, _, _ in
            //TODO: переход на эеран редактирования
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func loadEmployees() async throws{
        try await employees = server.fetchEmployees()
        DispatchQueue.main.async {
            self.employeeTable.reloadData()
        }
    }
    
    @objc private func refreshView() {
        Task {
            do {
                try await loadEmployees()
            } catch {
                print ("Ошибка загрузки сотрудников")
            }
        }
    }
    
    @objc private func addTapped() {
        //TODO: переход на экран редактирования
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Сотрудники"
        
        view.addSubview(employeeTable)
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
