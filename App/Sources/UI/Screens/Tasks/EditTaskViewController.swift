import UIKit

final class EditTaskViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var task: TaskEntity? = nil
    private var contextProject: ProjectEntity? = nil
    private let server = ServerManager.shared.currentServer
    private var projects: [ProjectEntity] = []
    private var employees: [EmployeeEntity] = []
    let dateFormatter = DateFormatter()
    
    private var saveButton: UIBarButtonItem!
    private var cancelButton: UIBarButtonItem!
    private var taskNameTF: UITextField!
    private var projectTF: UITextField!
    private var projectPV = UIPickerView()
    private var workTimeTF: UITextField!
    private var startDateTF: UITextField!
    private var endDateTF: UITextField!
    private var employeeTF: UITextField!
    private var employeePV = UIPickerView()
    private var statusSC: UISegmentedControl = {
        let items = TaskStatus.allCases.map {$0.rawValue}
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    weak var delegate: TasksViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ task: TaskEntity) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    init(project: ProjectEntity) {
        self.contextProject = project
        super.init(nibName: nil, bundle: nil)
    }
    
    init(_ task: TaskEntity, project: ProjectEntity) {
            self.task = task
            self.contextProject = project
            super.init(nibName: nil, bundle: nil)
        }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == projectPV {
            return projects.count
        } else {
            return employees.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == projectPV {
            return projects[row].projectName
        } else {
            let emp = employees[row]
            return "\(emp.lastName) \(emp.firstName) \(emp.surName ?? "")"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == projectPV {
            projectTF.text = projects[row].projectName
            view.endEditing(true)
        } else {
            let emp = employees[row]
            employeeTF.text = "\(emp.lastName) \(emp.firstName)"
            view.endEditing(true)
        }
    }
    
    private func loadData() async {
        do {
            try await projects = server.fetchProjects()
            try await employees = server.fetchEmployees()
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
            }
        } catch {
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
            }
            self.showAlert("Не удалось загрузить данные")
        }
    }
    
    private func createTextField(_ label: String, _ isEdit: Bool) -> UITextField{
        let textField = UITextField()
        if isEdit {
            textField.text = label
        } else {
            textField.placeholder = label
        }
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    private func setupPickerView(_ picker: UIPickerView, for textField: UITextField) {
        picker.dataSource = self
        picker.delegate = self
        textField.inputView = picker
    }
    
    private func setupSegmentedControl() {
        if let task {
            let index = TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
            statusSC.selectedSegmentIndex = index
        } else {
            statusSC.selectedSegmentIndex = 0
        }
    }
        
    private func setupTextFields() {
        var isEdit = false
        if let task {
            isEdit = true
            if let contextProject {
                projectTF = createTextField("\(contextProject.projectName)", isEdit)
                projectTF.isEnabled = false
                projectTF.textColor = .lightGray
            } else {
                projectTF = createTextField("\(projects.first(where: {$0.id == task.projectID})?.projectName ?? "")", isEdit)
            }
            taskNameTF = createTextField("\(task.taskName)", isEdit)
            workTimeTF = createTextField("\(task.workTime)", isEdit)
            startDateTF = createTextField(dateFormatter.string(from: task.startDate), isEdit)
            endDateTF = createTextField(dateFormatter.string(from: task.endDate), isEdit)
            var fio: String = ""
            if let emp = employees.first(where: {$0.id == task.employeeID}) {
                fio = "\(emp.lastName) \(emp.firstName) \(emp.surName ?? "")"
            }
            employeeTF = createTextField("\(fio)", isEdit)
        } else {
            if let contextProject {
                projectTF = createTextField("\(contextProject.projectName)", isEdit)
                projectTF.isEnabled = false
            } else {
                projectTF = createTextField("Выберите проект", isEdit)
            }
            taskNameTF = createTextField("Введите задачу", isEdit)
            workTimeTF = createTextField("Введите количество часов", isEdit)
            startDateTF = createTextField(dateFormatter.string(from: Date()), !isEdit)
            endDateTF = createTextField(dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: SettingsManager.shared.defaultDaysBetween, to: Date()) ?? Date()), !isEdit)
            employeeTF = createTextField("Выберите сотрудника", isEdit)
        }
    }
    
    @objc private func saveTask() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton.isEnabled = false
        Task {
            do {
                if let task {
                    var newTask = task
                    newTask.taskName = taskNameTF.text ?? ""
                    newTask.projectID = projects[projectPV.selectedRow(inComponent: 0)].id
                    newTask.workTime = Int(workTimeTF.text ?? "") ?? 0
                    newTask.startDate = dateFormatter.date(from: startDateTF.text ?? "") ?? Date()
                    newTask.endDate = dateFormatter.date(from: endDateTF.text ?? "") ?? Date()
                    //TODO: поменять конечную дату
                    newTask.status = TaskStatus.allCases[statusSC.selectedSegmentIndex]
                    newTask.employeeID = employees[employeePV.selectedRow(inComponent: 0)].id
                    
                    let savedTask = try await server.updateTask(newTask)
                    DispatchQueue.main.async {
                        self.delegate?.didUpdateTask(savedTask)
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.saveButton.isEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let newTask = TaskEntity(
                        taskName: taskNameTF.text ?? "",
                        projectID: projects[projectPV.selectedRow(inComponent: 0)].id,
                        workTime: Int(workTimeTF.text ?? "") ?? 0,
                        startDate: dateFormatter.date(from: startDateTF.text ?? "") ?? Date(),
                        endDate: dateFormatter.date(from: endDateTF.text ?? "") ?? Date(),
                        //TODO: поменять конечную дату
                        status: TaskStatus.allCases[statusSC.selectedSegmentIndex],
                        employeeID: employees[employeePV.selectedRow(inComponent: 0)].id
                    )
                    let savedTask = try await server.createTask(newTask)
                    DispatchQueue.main.async {
                        self.delegate?.didAddTask(savedTask)
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.saveButton.isEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                self.showAlert("Не удалось сохранить задачу")
            }
        }
    }
    
    @objc private func cancellView() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissObjects() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = (task != nil) ? "Редактирование задачи" : "Добавление задачи"
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveTask))
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancellView))
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissObjects))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton.isEnabled = false
        
        Task {
            await loadData()
            await MainActor.run {
                loadingIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
                saveButton.isEnabled = true
                setupTextFields()
                setupPickerView(projectPV, for: projectTF)
                setupPickerView(employeePV, for: employeeTF)
                setupSegmentedControl()
                
                view.addSubview(taskNameTF)
                view.addSubview(projectTF)
                view.addSubview(workTimeTF)
                view.addSubview(startDateTF)
                view.addSubview(endDateTF)
                view.addSubview(statusSC)
                view.addSubview(employeeTF)
                
                NSLayoutConstraint.activate([
                    taskNameTF.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                    taskNameTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    taskNameTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    
                    projectTF.topAnchor.constraint(equalTo: taskNameTF.bottomAnchor, constant: 30),
                    projectTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    projectTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    
                    workTimeTF.topAnchor.constraint(equalTo: projectTF.bottomAnchor, constant: 30),
                    workTimeTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    workTimeTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    
                    startDateTF.topAnchor.constraint(equalTo: workTimeTF.bottomAnchor, constant: 30),
                    startDateTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    startDateTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    
                    endDateTF.topAnchor.constraint(equalTo: startDateTF.bottomAnchor, constant: 30),
                    endDateTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    endDateTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    
                    statusSC.topAnchor.constraint(equalTo: endDateTF.bottomAnchor, constant: 30),
                    statusSC.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    statusSC.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    
                    employeeTF.topAnchor.constraint(equalTo: statusSC.bottomAnchor, constant: 30),
                    employeeTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    employeeTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
                    
                ])
            }
        }
    }
}
