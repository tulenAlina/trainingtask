import UIKit

final class EditTaskViewController1: BaseFormViewController {
    var onUpdate: ((ProjectTask) -> Void)?
    var onCreate: ((ProjectTask) -> Void)?
    
    private let server: Server
    private let settings: SettingsManager
    private var task: ProjectTask?
    private var contextProject: Project?
    private var projects: [Project] = []
    private var employees: [Employee] = []
    
    private let toolbar = UIToolbar()
    
    private let taskNameLabel = UIFactory.createDefaultLabel(text: Localized.nameLabel)
    private let projectLabel = UIFactory.createDefaultLabel(text: Localized.projectLabel)
    private let workTimeLabel = UIFactory.createDefaultLabel(text: Localized.hoursLabel)
    private let startDateLabel = UIFactory.createDefaultLabel(text: Localized.startDateLabel)
    private let endDateLabel = UIFactory.createDefaultLabel(text: Localized.endDateLabel)
    private let employeeLabel = UIFactory.createDefaultLabel(text: Localized.employeeLabel)
    private let statusLabel = UIFactory.createDefaultLabel(text: Localized.statusLabel)
    
    private var taskNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.taskNamePlaceholder)
    private var projectTextField = UIFactory.createDefaultTextField(placeholder: Localized.selectedProjectNamePlaceholder)
    private var workTimeTextField = UIFactory.createDefaultTextField(placeholder: Localized.workTimePlaceholder)
    private var startDateTextField = UIFactory.createDefaultTextField(placeholder: Localized.startDatePlaceholder)
    private var endDateTextField = UIFactory.createDefaultTextField(placeholder: Localized.endDatePlaceholder)
    private var employeeTextField = UIFactory.createDefaultTextField(placeholder: Localized.employeeNamePlaceholder)
   
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
        requiredFields = [taskNameTextField, projectTextField, workTimeTextField]
    }
    
    convenience init(task: ProjectTask? = nil, project: Project? = nil, server: Server, settings: SettingsManager, onUpdate: @escaping ((ProjectTask) -> Void)) {
        self.init(task: task, project: project, server: server, settings: settings)
        self.onUpdate = onUpdate
    }
    
    convenience init(task: ProjectTask? = nil, project: Project? = nil, server: Server, settings: SettingsManager, onCreate: @escaping ((ProjectTask) -> Void)) {
        self.init(task: task, project: project, server: server, settings: settings)
        self.onCreate = onCreate
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
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
        
        let isTaskNameChanged = taskNameTextField.text.unwrappedOrEmpty.trimmed != task.taskName.trimmed
        let isProjectChanged = projectTextField.text.unwrappedOrEmpty.trimmed != projectName
        let isWorkTimeChanged = workTimeTextField.text.unwrappedOrEmpty.trimmed.withoutSpaces.cleanedInt != task.workTime
        let isStartDateChanged = startDateTextField.text.unwrappedOrEmpty.trimmed != DateHelper.string(from: task.startDate)
        let isEndDateChanged = endDateTextField.text.unwrappedOrEmpty.trimmed != DateHelper.string(from: task.endDate)
        let isEmployeeChanged = employeeTextField.text.unwrappedOrEmpty.trimmed != empFio
        let isStatusChanged = statusSegmentedControl.selectedSegmentIndex != TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
        return isTaskNameChanged || isProjectChanged || isWorkTimeChanged || isStartDateChanged || isEndDateChanged || isEmployeeChanged || isStatusChanged
    }
    
    private func setupUI() {
        let title = (task != nil) ? Localized.editTask : Localized.addTask
        setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveTask))
        
        setupTextFields()
        setupFormRows()
        setupClearEmployeeButton()
        setupSegmentedControl()
        setupToolbar()
        setupForm()
        
        stackView.isHidden = true
    }
    
    private func setupTextFields() {
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
            selectedProject = contextProject ?? projects.first(where: { $0.id == task.projectID })
            projectTextField.text = selectedProject?.projectName ?? ""
            
            taskNameTextField.text = task.taskName
            workTimeTextField.text = "\(task.workTime)"
            startDateTextField.text = DateHelper.string(from: task.startDate)
            endDateTextField.text = DateHelper.string(from: task.endDate)
            
            selectedEmployee = employees.first(where: { $0.id == task.employeeID })
            employeeTextField.text = selectedEmployee?.fullName
            
        }

        taskNameTextField.delegate = self
        projectTextField.delegate = self
        workTimeTextField.delegate = self
        employeeTextField.delegate = self
        
        taskNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        projectTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        workTimeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupFormRows() {
        let taskNameRow = UIFactory.createVerticalFieldGroup(labelText: Localized.nameLabel, inputView: taskNameTextField)
        let projectRow = UIFactory.createVerticalFieldGroup(labelText: Localized.projectLabel, inputView: projectTextField)
        let workTimeRow = UIFactory.createVerticalFieldGroup(labelText: Localized.hoursLabel, inputView: workTimeTextField)
        let startDateRow = UIFactory.createVerticalFieldGroup(labelText: Localized.startDateLabel, inputView: startDateTextField)
        let endDateRow = UIFactory.createVerticalFieldGroup(labelText: Localized.endDateLabel, inputView: endDateTextField)
        let statusDateRow = UIFactory.createVerticalFieldGroup(labelText: Localized.statusLabel, inputView: statusSegmentedControl)
        
        let employeeHorizontalStack = UIStackView(arrangedSubviews: [employeeTextField, clearEmployeeButton])
        employeeHorizontalStack.axis = .horizontal
        employeeHorizontalStack.spacing = 5
        employeeHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let employeeRow = UIFactory.createVerticalFieldGroup(labelText: Localized.employeeLabel, inputView: employeeHorizontalStack)
        
        [taskNameRow, projectRow, workTimeRow, startDateRow, endDateRow, employeeRow, statusDateRow].forEach { row in
            stackView.addArrangedSubview(row)
        }
    }
    
    private func setupClearEmployeeButton() {
        clearEmployeeButton.addTarget(self, action: #selector(actionClearEmployee), for: .touchUpInside)
        clearEmployeeButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    private func setupSegmentedControl() {
        if let task {
            let index = TaskStatus.allCases.firstIndex { $0 == task.status } ?? 0
            statusSegmentedControl.selectedSegmentIndex = index
        } else {
            statusSegmentedControl.selectedSegmentIndex = 0
        }
    }
 
    private func setupToolbar() {
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(actionDateChange))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(actionEndEditing))
    
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
    }
    
    private func updateUI() {
        guard let task else { return }
        
        selectedProject = contextProject ?? projects.first(where: { $0.id == task.projectID })
        projectTextField.text = selectedProject?.projectName ?? ""
        
        selectedEmployee = employees.first(where: { $0.id == task.employeeID })
        employeeTextField.text = selectedEmployee?.fullName
        
        stackView.isHidden = false
        stopLoading()
    }
    
    private func updatedTask(_ task: ProjectTask, _ inputProject: Project, _ inputEmployee: Employee?) -> ProjectTask {
        let newTaskName = taskNameTextField.text.unwrappedOrEmpty.trimmed
        let newProjectID = inputProject.id
        let newWorkTime = workTimeTextField.text.unwrappedOrEmpty.withoutSpaces.cleanedInt
        let newStartDate = DateHelper.date(from: startDateTextField.text.unwrappedOrEmpty) ?? Date()
        let newEndDate = DateHelper.date(from: endDateTextField.text.unwrappedOrEmpty) ?? Calendar.current.date(byAdding: .day, value: settings.defaultDaysBetween, to: Date()) ?? Date()
        let newStatus = TaskStatus.allCases[statusSegmentedControl.selectedSegmentIndex]
        let newEmployeeID = inputEmployee?.id
        
        let updatedTask = ProjectTask(
            id: task.id,
            taskName: newTaskName,
            projectID: newProjectID,
            workTime: newWorkTime,
            startDate: newStartDate,
            endDate: newEndDate,
            status: newStatus,
            employeeID: newEmployeeID,
            createdAt: task.createdAt
        )
        
        return updatedTask
    }
    
    private func buildTask(_ inputProject: Project, _ inputEmployee: Employee?) -> ProjectTask {
        return ProjectTask(
            taskName: taskNameTextField.text.unwrappedOrEmpty.trimmed,
            projectID: inputProject.id,
            workTime: workTimeTextField.text.unwrappedOrEmpty.withoutSpaces.cleanedInt,
            startDate: DateHelper.date(from: startDateTextField.text.unwrappedOrEmpty) ?? Date(),
            endDate: DateHelper.date(from: endDateTextField.text.unwrappedOrEmpty) ?? Calendar.current.date(byAdding: .day, value: settings.defaultDaysBetween, to: Date()) ?? Date(),
            status: TaskStatus.allCases[statusSegmentedControl.selectedSegmentIndex],
            employeeID: inputEmployee?.id
        )
    }
    
    private func loadData() {
        startLoading()
        Task {
            do {
                async let allProjects = try await server.fetchProjects()
                async let allEmployees = try await server.fetchEmployees()
                
                let (projects, employees) = try await (allProjects, allEmployees)
                
                self.projects = projects
                self.employees = employees
                
                await MainActor.run {
                    updateUI()
                }
            } catch {
                await MainActor.run {
                    stopLoading()
                    showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    private func saveTask(_ inputProject: Project, _ inputEmployee: Employee?) async throws -> ProjectTask {
        if let task {
            let updatedTask = updatedTask(task, inputProject, inputEmployee)
            return try await server.updateTask(updatedTask)
        } else {
            let createdTask = buildTask(inputProject, inputEmployee)
            return try await server.createTask(createdTask)
            
        }
    }
    
    private func validateDates() -> Bool{
        guard let startDate = DateHelper.date(from: startDateTextField.text.unwrappedOrEmpty),
              let endDate = DateHelper.date(from: endDateTextField.text.unwrappedOrEmpty)
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
        
        let workTime = workTimeTextField.text.unwrappedOrEmpty.trimmed.cleanedInt
        
        guard workTime <= maxHours else {
            showAlert(Localized.hoursExceedPeriod)
            return false
        }
        
        return true
    }
    
    @objc private func actionSaveTask() {
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
                let savedTask = try await saveTask(selectedProject, selectedEmployee)
                await MainActor.run {
                    if task != nil {
                        onUpdate?(savedTask)
                    } else {
                        onCreate?(savedTask)
                    }
                    stopLoading()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    stopLoading()
                    showAlert(Localized.saveFailed)
                }
            }
        }
    }
    
    @objc private func actionDateChange(_ sender: UIDatePicker) {
        if startDateTextField.isFirstResponder {
            let dateString = DateHelper.string(from: startDatePicker.date)
            startDateTextField.text = dateString
        } else if endDateTextField.isFirstResponder {
            let dateString = DateHelper.string(from: endDatePicker.date)
            endDateTextField.text = dateString
        }
        
        actionEndEditing()
    }
    
    @objc private func actionSelectProject() {
        let projectsViewController = ProjectsViewController(server: server, settings: settings, mode: .selection(onSelect: { selectedProject in
            self.selectedProject = selectedProject
            self.projectTextField.text = selectedProject.projectName
            self.textFieldDidChange(sender: self.projectTextField)
        }))
        navigationController?.pushViewController(projectsViewController, animated: true)
    }
    
    @objc private func actionSelectEmployee() {
        let employeesViewController = EmployeesViewController(server: server, settings: settings, mode: .selection(onSelect: {
            selectedEmployee in
            self.selectedEmployee = selectedEmployee
            self.employeeTextField.text = selectedEmployee.fullName
        }))
        navigationController?.pushViewController(employeesViewController, animated: true)
    }
    
    @objc private func actionClearEmployee() {
        selectedEmployee = nil
        employeeTextField.text = nil
    }
}

extension EditTaskViewController1: UITextFieldDelegate {
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
            actionSelectProject()
        case employeeTextField:
            actionSelectEmployee()
        default:
            break
        }
    }
}
