import UIKit

final class EditTaskViewController: BaseFormViewController {
    weak var updateDelegate: TaskUpdateDelegate?
    weak var createDelegate: TaskCreateDelegate?
    
    private let server: Server
    private let settings: SettingsManager
    private var task: ProjectTask?
    private var contextProject: Project?
    private var projects: [Project] = []
    private var employees: [Employee] = []
    
    private let toolbar = UIToolbar()
    
    private let taskNameLabel = UIFactory.createLabel(text: Localized.nameLabel)
    private let projectLabel = UIFactory.createLabel(text: Localized.projectLabel)
    private let workTimeLabel = UIFactory.createLabel(text: Localized.hoursLabel)
    private let startDateLabel = UIFactory.createLabel(text: Localized.startDateLabel)
    private let endDateLabel = UIFactory.createLabel(text: Localized.endDateLabel)
    private let employeeLabel = UIFactory.createLabel(text: Localized.employeeLabel)
    private let statusLabel = UIFactory.createLabel(text: Localized.statusLabel)
    
    private var taskNameTextField = UIFactory.createTextField(placeholder: Localized.taskNamePlaceholder)
    private var projectTextField = UIFactory.createTextField(placeholder: Localized.selectedProjectNamePlaceholder)
    private var workTimeTextField = UIFactory.createTextField(placeholder: Localized.workTimePlaceholder)
    private var startDateTextField = UIFactory.createTextField(placeholder: Localized.startDatePlaceholder)
    private var endDateTextField = UIFactory.createTextField(placeholder: Localized.endDatePlaceholder)
    private var employeeTextField = UIFactory.createTextField(placeholder: Localized.employeeNamePlaceholder)
   
    private var selectedProject: Project?
    private var selectedEmployee: Employee?
    
    private let clearEmployeeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Localized.clear, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    private var statusSegmentedControl: UISegmentedControl = {
        let items = TaskStatus.allCases.map {$0.rawValue.localized}
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private init(task: ProjectTask? = nil, project: Project? = nil, server: Server, settings: SettingsManager) {
        self.task = task
        self.contextProject = project
        self.server = server
        self.settings = settings
        selectedProject = contextProject
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(task: ProjectTask? = nil, project: Project? = nil, server: Server, settings: SettingsManager, updateDelegate: TaskUpdateDelegate) {
        self.init(task: task, project: project, server: server, settings: settings)
        self.updateDelegate = updateDelegate
    }
    
    convenience init(task: ProjectTask? = nil, project: Project? = nil, server: Server, settings: SettingsManager, createDelegate: TaskCreateDelegate) {
        self.init(task: task, project: project, server: server, settings: settings)
        self.createDelegate = createDelegate
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle((task != nil) ? Localized.editTask : Localized.addTask)
        setupRequiredFields()
        loadInitialData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    private func setupRequiredFields() {
        requiredFields = [taskNameTextField, projectTextField, workTimeTextField]
    }
    
    private func setupUI() {
        setupTextFieldsAndLabels()
        setupClearEmployeeButton()
        setupSegmentedControl()
        setupConstraints()
        setupToolbar()
        addSaveButton(action: #selector(saveTask))
    }
        
    private func setupTextFieldsAndLabels() {
        if let contextProject {
            projectTextField.text = "\(contextProject.projectName)"
            projectTextField.isEnabled = false
            projectTextField.textColor = .lightGray
        }
        
        workTimeTextField.keyboardType = .numberPad
        
        startDateTextField.text = DateHelper.string(from: Date())
        startDateTextField.inputView = startDatePicker
        startDateTextField.inputAccessoryView = toolbar
        startDateTextField.delegate = self
        
        endDateTextField.text = DateHelper.string(from: Calendar.current.date(byAdding: .day, value: settings.defaultDaysBetween, to: Date()) ?? Date())
        endDateTextField.inputView = endDatePicker
        endDateTextField.inputAccessoryView = toolbar
        endDateTextField.delegate = self
        
        if let task {
            if contextProject == nil {
                selectedProject = projects.first(where: { $0.id == task.projectID })
                projectTextField.text = "\(selectedProject?.projectName ?? "")"
            }
            taskNameTextField.text = "\(task.taskName)"
            workTimeTextField.text = "\(task.workTime)"
            startDateTextField.text = DateHelper.string(from: task.startDate)
            endDateTextField.text = DateHelper.string(from: task.endDate)
            
            selectedEmployee = employees.first(where: { $0.id == task.employeeID })
            if selectedEmployee != nil {
                employeeTextField.text = selectedEmployee?.fullName
            }
        }

        taskNameTextField.delegate = self
        projectTextField.delegate = self
        workTimeTextField.delegate = self
        employeeTextField.delegate = self
        
        taskNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        projectTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        workTimeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view.addSubview(taskNameTextField)
        view.addSubview(taskNameLabel)
        view.addSubview(projectTextField)
        view.addSubview(projectLabel)
        view.addSubview(workTimeTextField)
        view.addSubview(workTimeLabel)
        view.addSubview(startDateTextField)
        view.addSubview(startDateLabel)
        view.addSubview(endDateTextField)
        view.addSubview(endDateLabel)
        view.addSubview(employeeTextField)
        view.addSubview(employeeLabel)
        view.addSubview(statusLabel)
    }
    
    private func setupClearEmployeeButton() {
        clearEmployeeButton.addTarget(self, action: #selector(clearEmployeeTapped), for: .touchUpInside)
        view.addSubview(clearEmployeeButton)
    }
    
    private func setupSegmentedControl() {
        if let task {
            let index = TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
            statusSegmentedControl.selectedSegmentIndex = index
        } else {
            statusSegmentedControl.selectedSegmentIndex = 0
        }
        
        view.addSubview(statusSegmentedControl)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            taskNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            taskNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            taskNameTextField.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: 5),
            taskNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            projectLabel.topAnchor.constraint(equalTo: taskNameTextField.bottomAnchor, constant: 10),
            projectLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            projectLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            projectTextField.topAnchor.constraint(equalTo: projectLabel.bottomAnchor, constant: 5),
            projectTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            projectTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            workTimeLabel.topAnchor.constraint(equalTo: projectTextField.bottomAnchor, constant: 10),
            workTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            workTimeTextField.topAnchor.constraint(equalTo: workTimeLabel.bottomAnchor, constant: 5),
            workTimeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workTimeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startDateLabel.topAnchor.constraint(equalTo: workTimeTextField.bottomAnchor, constant: 10),
            startDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            startDateTextField.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 5),
            startDateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startDateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            endDateLabel.topAnchor.constraint(equalTo: startDateTextField.bottomAnchor, constant: 10),
            endDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            endDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            endDateTextField.topAnchor.constraint(equalTo: endDateLabel.bottomAnchor, constant: 5),
            endDateTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            endDateTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            employeeLabel.topAnchor.constraint(equalTo: endDateTextField.bottomAnchor, constant: 10),
            employeeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            employeeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            employeeTextField.topAnchor.constraint(equalTo: employeeLabel.bottomAnchor, constant: 5),
            employeeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            employeeTextField.trailingAnchor.constraint(equalTo: clearEmployeeButton.leadingAnchor, constant: -20),
            
            clearEmployeeButton.topAnchor.constraint(equalTo: employeeLabel.bottomAnchor, constant: 5),
            clearEmployeeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clearEmployeeButton.widthAnchor.constraint(equalToConstant: 70),
            
            statusLabel.topAnchor.constraint(equalTo: employeeTextField.bottomAnchor, constant: 10),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusSegmentedControl.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 5),
            statusSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupToolbar() {
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(dateChanged))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(dismissObjects))
    
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
    }
    
    private func updatedTask(_ task: ProjectTask, _ inputProject: Project, _ inputEmployee: Employee?) -> ProjectTask {
        var updatedTask = task
        updatedTask.taskName = taskNameTextField.text?.trimmed ?? ""
        updatedTask.projectID = inputProject.id
        updatedTask.workTime = Int(workTimeTextField.text?.replacingOccurrences(of: " ", with: "") ?? "") ?? 0
        updatedTask.startDate = DateHelper.date(from: startDateTextField.text ?? "") ?? Date()
        updatedTask.endDate = DateHelper.date(from: endDateTextField.text ?? "") ?? Calendar.current.date(byAdding: .day, value: settings.defaultDaysBetween, to: Date()) ?? Date()
        updatedTask.status = TaskStatus.allCases[statusSegmentedControl.selectedSegmentIndex]
        updatedTask.employeeID = inputEmployee?.id
        return updatedTask
    }
    
    private func newTaskFromForm(_ inputProject: Project, _ inputEmployee: Employee?) -> ProjectTask {
        return ProjectTask(
            taskName: taskNameTextField.text?.trimmed ?? "",
            projectID: inputProject.id,
            workTime: Int(workTimeTextField.text?.replacingOccurrences(of: " ", with: "") ?? "") ?? 0,
            startDate: DateHelper.date(from: startDateTextField.text ?? "") ?? Date(),
            endDate: DateHelper.date(from: endDateTextField.text ?? "") ?? Calendar.current.date(byAdding: .day, value: settings.defaultDaysBetween, to: Date()) ?? Date(),
            status: TaskStatus.allCases[statusSegmentedControl.selectedSegmentIndex],
            employeeID: inputEmployee?.id
        )
    }
    
    private func loadInitialData() {
        startLoading()
        Task {
            await loadData()
            await MainActor.run {
                setupUI()
                stopLoading()
            }
        }
    }
    
    private func loadData() async {
        do {
            async let allProjects = try await server.fetchProjects()
            async let allEmployees = try await server.fetchEmployees()
            
            let (projects, employees) = try await (allProjects, allEmployees)
            
            self.projects = projects
            self.employees = employees
        } catch {
            await MainActor.run {
                showAlert(Localized.loadFailed)
            }
        }
    }
    
    private func fetchSavedTask(_ inputProject: Project, _ inputEmployee: Employee?) async throws -> ProjectTask {
        if let task {
            let updatedTask = updatedTask(task, inputProject, inputEmployee)
            return try await server.updateTask(updatedTask)
        } else {
            let createdTask = newTaskFromForm(inputProject, inputEmployee)
            return try await server.createTask(createdTask)
            
        }
    }
    
    private func handleSuccess(savedTask: ProjectTask) {
        if task != nil {
            updateDelegate?.didUpdateTask(savedTask)
        } else {
            createDelegate?.didCreateTask(savedTask)
        }
        stopLoading()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func validateDates() -> Bool{
        guard let startDate = DateHelper.date(from: startDateTextField.text ?? ""),
              let endDate = DateHelper.date(from: endDateTextField.text ?? "")
        else {
            showAlert(Localized.invalidDate)
            return false
        }
        
        guard endDate >= startDate else {
            showAlert(Localized.dateEndBeforeStart)
            return false
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let daysBetween = components.day ?? 0
        let maxHours = (daysBetween + 1) * 24
        
        let workTime = Int(workTimeTextField.text?.trimmed ?? "") ?? 0
        
        guard workTime <= maxHours else {
            showAlert(Localized.hoursExceedPeriod)
            return false
        }
        
        return true
    }
    
    override func isFieldsChanged() -> Bool {
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
        let workTimeChanged = Int(workTimeTextField.text?.trimmed.replacingOccurrences(of: " ", with: "") ?? "") ?? 0 != task.workTime
        let startDateChanged = startDateTextField.text?.trimmed ?? "" != DateHelper.string(from: task.startDate)
        let endDateChanged = endDateTextField.text?.trimmed ?? "" != DateHelper.string(from: task.endDate)
        let employeeChanged = employeeTextField.text?.trimmed ?? "" != empFio
        let statusChanged = statusSegmentedControl.selectedSegmentIndex != TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
        return taskNameChanged || projectChanged || workTimeChanged || startDateChanged || endDateChanged || employeeChanged || statusChanged
    }
    
    @objc private func saveTask() {
        guard validateFields() else { return }
        guard isFieldsChanged() else {
            navigationController?.popViewController(animated: true)
            return
        }
        guard let selectedProject else { return }
        guard validateDates() else {return}
        startLoading()
        
        Task {
            do {
                let savedTask = try await fetchSavedTask(selectedProject, selectedEmployee)
                await MainActor.run {
                    handleSuccess(savedTask: savedTask)
                }
            } catch {
                await MainActor.run {
                    stopLoading()
                    showAlert(Localized.saveFailed)
                }
            }
        }
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        if startDateTextField.isFirstResponder {
            let dateString = DateHelper.string(from: startDatePicker.date)
            startDateTextField.text = dateString
        } else if endDateTextField.isFirstResponder {
            let dateString = DateHelper.string(from: endDatePicker.date)
            endDateTextField.text = dateString
        }
        
        dismissObjects()
    }
    
    @objc private func selectProjectTapped() {
        let projectsViewController = ProjectsViewController(mode: .selection {[weak self] selectedProject in
            if let self {
                self.selectedProject = selectedProject
                self.projectTextField.text = selectedProject.projectName
                self.textFieldDidChange(sender: self.projectTextField)
            }
        }, server: server, settings: settings)
        navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
    @objc private func selectEmployeeTapped() {
        let employeesViewController = EmployeesViewController(mode: .selection {[weak self] selectedEmployee in
            self?.selectedEmployee = selectedEmployee
            self?.employeeTextField.text = selectedEmployee.fullName
        }, server: server, settings: settings)
        navigationController?.pushViewController(employeesViewController, animated: true)
    }
    
    @objc private func clearEmployeeTapped() {
        selectedEmployee = nil
        employeeTextField.text = nil
    }
}

extension EditTaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case workTimeTextField:
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        case projectTextField:
            return false
        case employeeTextField:
            return false
        case startDateTextField:
            return false
        case endDateTextField:
            return false
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case startDateTextField:
            if let text = textField.text, let date = DateHelper.date(from: text) {
                startDatePicker.date = date
            }
        case endDateTextField:
            if let text = textField.text, let date = DateHelper.date(from: text) {
                endDatePicker.date = date
            }
        case projectTextField:
            selectProjectTapped()
        case employeeTextField:
            selectEmployeeTapped()
        default:
            break
        }
    }
}
