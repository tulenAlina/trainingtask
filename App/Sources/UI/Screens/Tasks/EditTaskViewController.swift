import UIKit

final class EditTaskViewController: UIViewController {
    
    weak var delegate: TasksViewControllerDelegate?
    var saveButton: UIBarButtonItem!
    
    private let server: Server
    private let settings: SettingsManager
    private let dateFormatter = DateHelper.self
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private var task: ProjectTask?
    private var contextProject: Project?
    private var projects: [Project] = []
    private var employees: [Employee] = []
    private var cancelButton: UIBarButtonItem!
    private var taskNameTextField: UITextField!
    private var projectTextField: UITextField!
    private var workTimeTextField: UITextField!
    private var startDateTextField: UITextField!
    private var endDateTextField: UITextField!
    private var employeeTextField: UITextField!
    
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
    
    private let projectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localized.Action.select.localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let employeeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localized.Action.select.localized, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var statusSegmentedControl: UISegmentedControl = {
        let items = TaskStatus.allCases.map {$0.rawValue.localized}
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    init(task: ProjectTask? = nil, project: Project? = nil, server: Server, settings: SettingsManager) {
        self.task = task
        self.contextProject = project
        self.server = server
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = (task != nil) ? Localized.Screen.editTask.localized : Localized.Screen.addTask.localized
        setupLoadingIndicator()
        loadInitialData()
    }
    
    private func setupUI() {
        setupTextFields()
        setupButtons()
        setupSegmentedControl()
        setupDatePickers()
        setupNavigationBar()
        setupTapGesture()
        setupConstraints()
    }
    
    private func setupButtons() {
        projectButton.addTarget(self, action: #selector(selectProjectTapped), for: .touchUpInside)
        employeeButton.addTarget(self, action: #selector(selectEmployeeTapped), for: .touchUpInside)
        if contextProject != nil {
            projectButton.isEnabled = false
        }
        view.addSubview(projectButton)
        view.addSubview(employeeButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            taskNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            taskNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            projectTextField.topAnchor.constraint(equalTo: taskNameTextField.bottomAnchor, constant: 30),
            projectTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            projectTextField.trailingAnchor.constraint(equalTo: projectButton.leadingAnchor, constant: -20),
            
            projectButton.topAnchor.constraint(equalTo: taskNameTextField.bottomAnchor, constant: 30),
            projectButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            workTimeTextField.topAnchor.constraint(equalTo: projectTextField.bottomAnchor, constant: 30),
            workTimeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workTimeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startDateTextField.topAnchor.constraint(equalTo: workTimeTextField.bottomAnchor, constant: 30),
            startDateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startDateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            endDateTextField.topAnchor.constraint(equalTo: startDateTextField.bottomAnchor, constant: 30),
            endDateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            endDateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusSegmentedControl.topAnchor.constraint(equalTo: endDateTextField.bottomAnchor, constant: 30),
            statusSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            employeeButton.topAnchor.constraint(equalTo: statusSegmentedControl.bottomAnchor, constant: 30),
            employeeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            employeeTextField.topAnchor.constraint(equalTo: statusSegmentedControl.bottomAnchor, constant: 30),
            employeeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            employeeTextField.trailingAnchor.constraint(equalTo: employeeButton.leadingAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        saveButton = UIBarButtonItem(title: Localized.Action.save.localized, style: .done, target: self, action: #selector(saveTask))
        navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissObjects))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSegmentedControl() {
        if let task {
            let index = TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
            statusSegmentedControl.selectedSegmentIndex = index
        } else {
            statusSegmentedControl.selectedSegmentIndex = 0
        }
        
        statusSegmentedControl.addTarget(self, action: #selector(updateSaveButtonState), for: .valueChanged)
    }
    
    private func setupDatePickers() {
        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker
        startDateTextField.delegate = self
        endDateTextField.delegate = self
        
        startDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
        
    private func setupTextFields() {
        var isEdit = false
        if let task {
            isEdit = true
            if let contextProject {
                projectTextField = UITextField.create(text: "\(contextProject.projectName)", placeholder: Localized.Placeholder.projectName.localized, isEdit: isEdit)
                projectTextField.isEnabled = false
                projectTextField.textColor = .lightGray
            } else {
                projectTextField = UITextField.create(text: "\(projects.first(where: {$0.id == task.projectID})?.projectName ?? "")", placeholder: Localized.Placeholder.projectName.localized, isEdit: isEdit)
            }
            taskNameTextField = UITextField.create(text: "\(task.taskName)", placeholder: Localized.Placeholder.taskName.localized, isEdit: isEdit)
            
            workTimeTextField = UITextField.create(text: "\(task.workTime)", placeholder: Localized.Placeholder.workTime.localized, isEdit: isEdit)
            workTimeTextField.keyboardType = .numberPad
            workTimeTextField.delegate = self
            
            startDateTextField = UITextField.create(text: dateFormatter.string(from: task.startDate), placeholder: Localized.Placeholder.startDate.localized,  isEdit: isEdit)
            endDateTextField = UITextField.create(text: dateFormatter.string(from: task.endDate), placeholder: Localized.Placeholder.endDate.localized, isEdit: isEdit)
            var fio: String = ""
            if let emp = employees.first(where: {$0.id == task.employeeID}) {
                fio = emp.fullName
            }
            employeeTextField = UITextField.create(text: "\(fio)", placeholder: Localized.Placeholder.employeeName.localized, isEdit: isEdit)
        } else {
            if let contextProject {
                projectTextField = UITextField.create(text: "\(contextProject.projectName)", placeholder: Localized.Placeholder.projectName.localized, isEdit: !isEdit)
                projectTextField.isEnabled = false
                projectTextField.textColor = .lightGray
            } else {
                projectTextField = UITextField.create(placeholder: Localized.Placeholder.projectName.localized, isEdit: isEdit)
            }
            taskNameTextField = UITextField.create(placeholder: Localized.Placeholder.taskName.localized, isEdit: isEdit)
            
            workTimeTextField = UITextField.create(placeholder: Localized.Placeholder.workTime.localized, isEdit: isEdit)
            workTimeTextField.keyboardType = .numberPad
            workTimeTextField.delegate = self
            
            startDateTextField = UITextField.create(text: dateFormatter.string(from: Date()), placeholder: Localized.Placeholder.startDate.localized, isEdit: !isEdit)
            endDateTextField = UITextField.create(text: dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: settings.defaultDaysBetween, to: Date()) ?? Date()), placeholder: Localized.Placeholder.endDate.localized, isEdit: !isEdit)
            employeeTextField = UITextField.create(placeholder: Localized.Placeholder.employeeName.localized, isEdit: isEdit)
        }
        
        taskNameTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        projectTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        workTimeTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        startDateTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        endDateTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        employeeTextField.addTarget(self, action: #selector(updateSaveButtonState), for: .editingChanged)
        
        view.addSubview(taskNameTextField)
        view.addSubview(projectTextField)
        view.addSubview(workTimeTextField)
        view.addSubview(startDateTextField)
        view.addSubview(endDateTextField)
        view.addSubview(statusSegmentedControl)
        view.addSubview(employeeTextField)
    }
    
    private func validateDates() -> Bool{
        guard let startDate = dateFormatter.date(from: startDateTextField.text ?? ""),
              let endDate = dateFormatter.date(from: endDateTextField.text ?? "")
        else {
            showAlert(Localized.Error.invalidDate.localized)
            return false
        }
        
        guard endDate >= startDate else {
            showAlert(Localized.Error.dateEndBeforeStart.localized)
            return false
        }
        return true
    }
    
    private func validateProject() -> Project?{
        guard let inputProject = projects.first(where: {$0.projectName.trimmed == projectTextField.text?.trimmed ?? ""})
        else {
            showAlert(Localized.Error.selectProject.localized)
            return nil
        }
        return inputProject
    }
    
    private func validateEmployee() -> (Employee?, Bool) {
        if employeeTextField.text?.trimmed.isBlank ?? true {
            return (nil, true)
        }
        
        guard let inputEmployee = employees.first(where: {emp in
            return emp.fullName == employeeTextField.text?.trimmed ?? ""
        })
        else {
            showAlert(Localized.Error.selectEmployee.localized)
            return (nil, false)
        }
        return (inputEmployee, true)
    }
    
    private func loadInitialData() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        Task {
            await loadData()
            await MainActor.run {
                setupUI()
                loadingIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
                updateSaveButtonState()
            }
        }
    }
    
    private func loadData() async {
        do {
            projects = try await server.fetchProjects()
            employees = try await server.fetchEmployees()
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
            }
        } catch {
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
            }
            self.showAlert(Localized.Error.loadFailed.localized)
        }
    }
    
    private func startLoading() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        saveButton.isEnabled = false
    }
    
    private func stopLoading() {
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
        saveButton.isEnabled = true
    }
    
    private func prepareUpdateData(_ inputProject: Project, _ inputEmployee: Employee?) -> ProjectTask {
        var updatedTask = task!
        updatedTask.taskName = taskNameTextField.text?.trimmed ?? ""
        updatedTask.projectID = inputProject.id
        updatedTask.workTime = Int(workTimeTextField.text ?? "") ?? 0
        updatedTask.startDate = dateFormatter.date(from: startDateTextField.text ?? "") ?? Date()
        updatedTask.endDate = dateFormatter.date(from: endDateTextField.text ?? "") ?? Calendar.current.date(byAdding: .day, value: settings.defaultDaysBetween, to: Date()) ?? Date()
        updatedTask.status = TaskStatus.allCases[statusSegmentedControl.selectedSegmentIndex]
        updatedTask.employeeID = inputEmployee?.id
        return updatedTask
    }
    
    private func prepareCreateData(_ inputProject: Project, _ inputEmployee: Employee?) -> ProjectTask {
        return ProjectTask(
            taskName: taskNameTextField.text?.trimmed ?? "",
            projectID: inputProject.id,
            workTime: Int(workTimeTextField.text ?? "") ?? 0,
            startDate: dateFormatter.date(from: startDateTextField.text ?? "") ?? Date(),
            endDate: dateFormatter.date(from: endDateTextField.text ?? "") ?? Calendar.current.date(byAdding: .day, value: settings.defaultDaysBetween, to: Date()) ?? Date(),
            status: TaskStatus.allCases[statusSegmentedControl.selectedSegmentIndex],
            employeeID: inputEmployee?.id
        )
    }
    
    private func handleSuccess(savedTask: ProjectTask) {
        if task != nil {
            delegate?.didUpdateTask(savedTask)
        } else {
            delegate?.didAddTask(savedTask)
        }
        stopLoading()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func performSave(_ inputProject: Project, _ inputEmployee: Employee?) async throws -> ProjectTask {
        if task != nil {
            let updatedTask = prepareUpdateData(inputProject, inputEmployee)
            return try await server.updateTask(updatedTask)
        } else {
            let createdTask = prepareCreateData(inputProject, inputEmployee)
            return try await server.createTask(createdTask)
            
        }
    }
    
    @objc private func saveTask() {
        let isValidateEmployee = validateEmployee()
        guard validateDates() && isValidateEmployee.1 else {return}
        guard let inputProject = validateProject() else {return}
        let inputEmployee = isValidateEmployee.0
        startLoading()
        
        Task {
            do {
                let savedTask = try await performSave(inputProject, inputEmployee)
                DispatchQueue.main.async {
                    self.handleSuccess(savedTask: savedTask)
                }
            } catch {
                await MainActor.run {
                    self.showAlert(Localized.Error.saveFailed.localized)
                }
            }
        }
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let dateString = dateFormatter.string(from: sender.date)
        
        if sender == startDatePicker {
            startDateTextField.text = dateString
        } else if sender == endDatePicker {
            endDateTextField.text = dateString
        }
        
        updateSaveButtonState()
    }
    
    @objc private func dismissObjects() {
        view.endEditing(true)
    }
    
    @objc private func updateSaveButtonState() {
        saveButton.isEnabled = isFormValid
    }
    
    @objc private func selectProjectTapped() {
        let projectsViewController = ProjectsViewController(mode: .selection {[weak self] selectedProject in
            self?.projectTextField.text = selectedProject.projectName
            self?.updateSaveButtonState()
        }, server: server, settings: settings)
        navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
    @objc private func selectEmployeeTapped() {
        let employeesViewController = EmployeesViewController(mode: .selection {[weak self] selectedEmployee in
            self?.employeeTextField.text = selectedEmployee.fullName
            self?.updateSaveButtonState()
        }, server: server, settings: settings)
        navigationController?.pushViewController(employeesViewController, animated: true)
    }
}

extension EditTaskViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == workTimeTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == startDateTextField {
            if let text = textField.text, let date = dateFormatter.date(from: text) {
                startDatePicker.date = date
            }
        } else if textField == endDateTextField {
            if let text = textField.text, let date = dateFormatter.date(from: text) {
                endDatePicker.date = date
            }
        }
    }
}

extension EditTaskViewController: FormValidatable {
    var isFieldsChanged: Bool {
        guard let task = task else { return true }
        
        var projectName: String = ""
        if let prj = projects.first(where: {$0.id == task.projectID}) {
            projectName = prj.projectName
        }
        
        var empFio: String = ""
        if let emp = employees.first(where: {$0.id == task.employeeID}) {
            empFio = emp.fullName
        }
        
        let taskNameChanged = taskNameTextField.text?.trimmed ?? "" != task.taskName.trimmed
        let projectChanged = projectTextField.text?.trimmed ?? "" != projectName
        let workTimeChanged = Int(workTimeTextField.text?.trimmed ?? "") ?? 0 != task.workTime
        let startDateChanged = startDateTextField.text?.trimmed ?? "" != dateFormatter.string(from: task.startDate)
        let endDateChanged = endDateTextField.text?.trimmed ?? "" != dateFormatter.string(from: task.endDate)
        let employeeChanged = employeeTextField.text?.trimmed ?? "" != empFio
        let statusChanged = statusSegmentedControl.selectedSegmentIndex != TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
        return taskNameChanged || projectChanged || workTimeChanged || startDateChanged || endDateChanged || employeeChanged || statusChanged
    }
                                                                                   
    var isFormFilled: Bool {
        let isTaskNameFilled = !(taskNameTextField.text?.trimmed.isBlank ?? true)
        let isProjectFilled = !(projectTextField.text?.trimmed.isBlank ?? true)
        let isWorkTimeFilled = !(workTimeTextField.text?.trimmed.isBlank ?? true)
        let isStartDateFilled = !(startDateTextField.text?.trimmed.isBlank ?? true)
        let isEndDateFilled = !(endDateTextField.text?.trimmed.isBlank ?? true)
        return isTaskNameFilled && isProjectFilled && isWorkTimeFilled && isStartDateFilled && isEndDateFilled
    }
}
