import UIKit

final class EditTaskViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
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
    
    private let startDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.locale = Locale(identifier: "ru_RU")
        return picker
    }()
    
    private let endDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.locale = Locale(identifier: "ru_RU")
        return picker
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
            return "\(emp.lastName) \(emp.firstName) \(emp.surName ?? "")".trimmed
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == projectPV {
            projectTF.text = projects[row].projectName
            view.endEditing(true)
        } else {
            let emp = employees[row]
            employeeTF.text = "\(emp.lastName) \(emp.firstName) \(emp.surName ?? "")".trimmed
            view.endEditing(true)
        }
        updateSaveButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == workTimeTF {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    private func validateDates() -> Bool{
        guard let startDate = dateFormatter.date(from: startDateTF.text ?? ""),
              let endDate = dateFormatter.date(from: endDateTF.text ?? "")
        else {
            showAlert("Неверный формат даты")
            return false
        }
        
        guard endDate >= startDate else {
            showAlert("Дата окончания должна быть позже даты начала")
            return false
        }
        return true
    }
    
    private func validateProject() -> ProjectEntity?{
        guard let inputProject = projects.first(where: {$0.projectName.trimmed == projectTF.text?.trimmed ?? ""})
        else {
            showAlert("Выберите проект из списка")
            return nil
        }
        return inputProject
    }
    
    private func validateEmployee() -> (EmployeeEntity?, Bool) {
        if employeeTF.text?.trimmed.isBlank ?? true {
            return (nil, true)
        }
        
        guard let inputEmployee = employees.first(where: {emp in
            let fio = "\(emp.lastName) \(emp.firstName) \(emp.surName ?? "")".trimmed
            return fio == employeeTF.text?.trimmed ?? ""
        })
        else {
            showAlert("Выберите сотрудника из списка")
            return (nil, false)
        }
        return (inputEmployee, true)
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
    
    private func setupDatePickers() {
        startDateTF.inputView = startDatePicker
        endDateTF.inputView = endDatePicker
        
        startDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
        
    private func setupTextFields() {
        var isEdit = false
        if let task {
            isEdit = true
            if let contextProject {
                projectTF = UITextField.create(text: "\(contextProject.projectName)", placeholder: "Выберите проект", isEdit: isEdit)
                projectTF.isEnabled = false
                projectTF.textColor = .lightGray
            } else {
                projectTF = UITextField.create(text: "\(projects.first(where: {$0.id == task.projectID})?.projectName ?? "")", placeholder: "Выберите проект", isEdit: isEdit)
            }
            taskNameTF = UITextField.create(text: "\(task.taskName)", placeholder: "Введите задачу", isEdit: isEdit)
            
            workTimeTF = UITextField.create(text: "\(task.workTime)", placeholder: "Введите количество часов", isEdit: isEdit)
            workTimeTF.keyboardType = .numberPad
            workTimeTF.delegate = self
            
            startDateTF = UITextField.create(text: dateFormatter.string(from: task.startDate), placeholder: "Введите дату начала (ГГГГ-ММ-ДД)",  isEdit: isEdit)
            endDateTF = UITextField.create(text: dateFormatter.string(from: task.endDate), placeholder: "Введите дату окончания (ГГГГ-ММ-ДД)", isEdit: isEdit)
            var fio: String = ""
            if let emp = employees.first(where: {$0.id == task.employeeID}) {
                fio = "\(emp.lastName) \(emp.firstName) \(emp.surName ?? "")".trimmed
            }
            employeeTF = UITextField.create(text: "\(fio)", placeholder: "Выберите сотрудника", isEdit: isEdit)
        } else {
            if let contextProject {
                projectTF = UITextField.create(text: "\(contextProject.projectName)", placeholder: "Выберите проект", isEdit: !isEdit)
                projectTF.isEnabled = false
                projectTF.textColor = .lightGray
            } else {
                projectTF = UITextField.create(placeholder: "Выберите проект", isEdit: isEdit)
            }
            taskNameTF = UITextField.create(placeholder: "Введите задачу", isEdit: isEdit)
            
            workTimeTF = UITextField.create(placeholder: "Введите количество часов", isEdit: isEdit)
            workTimeTF.keyboardType = .numberPad
            workTimeTF.delegate = self
            
            startDateTF = UITextField.create(text: dateFormatter.string(from: Date()), placeholder: "Введите дату начала (ГГГГ-ММ-ДД)", isEdit: !isEdit)
            endDateTF = UITextField.create(text: dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: SettingsManager.shared.defaultDaysBetween, to: Date()) ?? Date()), placeholder: "Введите дату окончания (ГГГГ-ММ-ДД)", isEdit: !isEdit)
            employeeTF = UITextField.create(placeholder: "Выберите сотрудника", isEdit: isEdit)
        }
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let dateString = dateFormatter.string(from: sender.date)
        
        if sender == startDatePicker {
            startDateTF.text = dateString
        } else if sender == endDatePicker {
            endDateTF.text = dateString
        }
        
        updateSaveButtonState()
    }
    
    @objc private func saveTask() {
        let isValidateEmployee = validateEmployee()
        guard validateDates() && isValidateEmployee.1 else {return}
        guard let inputProject = validateProject() else {return}
        let inputEmployee = isValidateEmployee.0
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton.isEnabled = false
        Task {
            do {
                if let task {
                    var newTask = task
                    newTask.taskName = taskNameTF.text?.trimmed ?? ""
                    newTask.projectID = inputProject.id
                    newTask.workTime = Int(workTimeTF.text ?? "") ?? 0
                    newTask.startDate = dateFormatter.date(from: startDateTF.text ?? "") ?? Date()
                    newTask.endDate = dateFormatter.date(from: endDateTF.text ?? "") ?? Calendar.current.date(byAdding: .day, value: SettingsManager.shared.defaultDaysBetween, to: Date()) ?? Date()
                    newTask.status = TaskStatus.allCases[statusSC.selectedSegmentIndex]
                    newTask.employeeID = inputEmployee?.id
                    
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
                        taskName: taskNameTF.text?.trimmed ?? "",
                        projectID: inputProject.id,
                        workTime: Int(workTimeTF.text ?? "") ?? 0,
                        startDate: dateFormatter.date(from: startDateTF.text ?? "") ?? Date(),
                        endDate: dateFormatter.date(from: endDateTF.text ?? "") ?? Calendar.current.date(byAdding: .day, value: SettingsManager.shared.defaultDaysBetween, to: Date()) ?? Date(),
                        status: TaskStatus.allCases[statusSC.selectedSegmentIndex],
                        employeeID: inputEmployee?.id
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
    
    @objc private func dismissObjects() {
        view.endEditing(true)
    }
    
    @objc private func updateSaveButtonState() {
        var isFieldsMatched = false
        if let task {
            var empFio: String = ""
            if let emp = employees.first(where: {$0.id == task.employeeID}) {
                empFio = "\(emp.lastName) \(emp.firstName) \(emp.surName ?? "")".trimmed
            }
            
            isFieldsMatched = (taskNameTF.text?.trimmed ?? "" == task.taskName.trimmed) && (projectTF.text?.trimmed ?? "" == projects.first {$0.id == task.projectID}?.projectName.trimmed ?? "") && (Int(workTimeTF.text?.trimmed ?? "") ?? 0 == task.workTime) && (startDateTF.text?.trimmed ?? "" == dateFormatter.string(from: task.startDate)) && (endDateTF.text?.trimmed ?? "" == dateFormatter.string(from: task.endDate) && employeeTF.text?.trimmed ?? "" == empFio) && (statusSC.selectedSegmentIndex == TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0)
        }
        let isTaskNameFilled = !(taskNameTF.text?.trimmed.isBlank ?? true)
        let isProjectFilled = !(projectTF.text?.trimmed.isBlank ?? true)
        let isWorkTimeFilled = !(workTimeTF.text?.trimmed.isBlank ?? true)
        let isStartDateFilled = !(startDateTF.text?.trimmed.isBlank ?? true)
        let isEndDateFilled = !(endDateTF.text?.trimmed.isBlank ?? true)
        
        saveButton.isEnabled = !isFieldsMatched && isTaskNameFilled && isProjectFilled && isWorkTimeFilled && isStartDateFilled && isEndDateFilled
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = (task != nil) ? "Редактирование" : "Cоздание"
        
        saveButton = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTask))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
        
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
        
        Task {
            await loadData()
            await MainActor.run {
                loadingIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
                setupTextFields()
                setupPickerView(projectPV, for: projectTF)
                setupPickerView(employeePV, for: employeeTF)
                setupSegmentedControl()
                setupDatePickers()
                
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
                
                taskNameTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
                projectTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
                workTimeTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
                startDateTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
                endDateTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
                employeeTF.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
                statusSC.addTarget(self, action: #selector(updateSaveButtonState), for: .valueChanged)
                
                updateSaveButtonState()
            }
        }
    }
}
