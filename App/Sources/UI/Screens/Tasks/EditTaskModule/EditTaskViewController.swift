import UIKit

enum EditTaskFieldType {
    case taskName
    case project
    case workTime
    case startDate
    case endDate
    case employee
}

protocol EditTaskViewInputProtocol: AnyObject {
    var requiredFields: [UITextField] { get }
    
    func setupNavigationBar(title: String)
    func setupSegmentedControl(index: Int)
    func updateProjectName(_ name: String)
    func updateEmployeeName(_ name: String)
    func setProjectField(projectName: String)
    func setEndDateField(defaultDaysBetween: Int)
    func setTaskFields(taskName: String, projectName: String, workTime: String, startDate: String, endDate: String, employee: String?)
    func applyValidationResults(_ fieldsValidity: [Bool])
    func updateValidationStyle(textFieldType: EditTaskFieldType, isValid: Bool)
    func startLoading()
    func stopLoading()
    func showAlert(_ message: String)
}

protocol EditTaskViewOutputProtocol {
    func viewDidLoad()
    func didTapSaveButton(taskNameString: String, workTime: String, startDateString: String, endDateString: String, statusIndex: Int)
    func didTapClearEmployee()
    func didTapSelectProject()
    func didTapSelectEmployee()
    func textFieldDidChange(textFieldType: EditTaskFieldType, text: String?)
}

final class EditTaskViewController: BaseViewController, EditTaskViewInputProtocol {
    var output: EditTaskViewOutputProtocol
    
    var requiredFields: [UITextField] {
        [taskNameTextField, projectTextField, workTimeTextField]
    }
    
    private let toolbar = UIToolbar()
    private let taskEditView = ValidatableFormView()
    
    private let taskNameTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.taskNamePlaceholder)
    private let projectTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.selectedProjectNamePlaceholder)
    private let workTimeTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.workTimePlaceholder)
    private let startDateTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.startDatePlaceholder)
    private let endDateTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.endDatePlaceholder)
    private let employeeTextField = TextFieldFactory.createDefaultTextField(placeholder: Localized.employeeNamePlaceholder)
    
    private let statusSegmentedControl = SegmentedControlFactory.createSegmentedControl(items: TaskStatus.allCases.map {$0.rawValue.localized})
    
    private let startDatePicker = DatePickerFactory.createDatePicker()
    private let endDatePicker = DatePickerFactory.createDatePicker()
    private let clearEmployeeButton = ButtonFactory.createClearButton()
    
    private lazy var employeeHorizontalStack = StackViewFactory.createHorizontalStackView(views: [employeeTextField, clearEmployeeButton], spacing: 5)
    
    init(presenter: EditTaskViewOutputProtocol) {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    func setupNavigationBar(title: String) {
        super.setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveTask))
    }
    
    func setupSegmentedControl(index: Int) {
        statusSegmentedControl.selectedSegmentIndex = index
    }
    
    func updateProjectName(_ name: String) {
        projectTextField.text = name
        output.textFieldDidChange(textFieldType: .project, text: name)
    }
    
    func updateEmployeeName(_ name: String) {
        employeeTextField.text = name
    }
    
    func setProjectField(projectName: String) {
        projectTextField.text = projectName
        projectTextField.isEnabled = false
        projectTextField.textColor = .lightGray
    }
    
    func setEndDateField(defaultDaysBetween: Int) {
        endDateTextField.text = DateHelper.string(from: Calendar.current.date(byAdding: .day, value: defaultDaysBetween, to: Date()) ?? Date())
    }
    
    func setTaskFields(taskName: String, projectName: String, workTime: String, startDate: String, endDate: String, employee: String?) {
        taskNameTextField.text = taskName
        projectTextField.text = projectName
        workTimeTextField.text = workTime
        startDateTextField.text = startDate
        endDateTextField.text = endDate
        employeeTextField.text = employee
    }
    
    func applyValidationResults(_ fieldsValidity: [Bool]) {
        var result: [ValidatedField] = []
        for i in 0..<requiredFields.count {
            result.append(ValidatedField(textField: requiredFields[i], isValid: fieldsValidity[i]))
        }
        taskEditView.applyValidationResults(result)
    }
    
    func updateValidationStyle(textFieldType: EditTaskFieldType, isValid: Bool) {
        let textField: UITextField?
            switch textFieldType {
            case .taskName:
                textField = taskNameTextField
            case .project:
                textField = projectTextField
            case .workTime:
                textField = workTimeTextField
            default:
                textField = nil
            }
        guard let textField else { return }
        taskEditView.applyValidationStyle(textField, isValid: isValid)
    }
}

// MARK: - UITextFieldDelegate

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
            output.didTapSelectProject()
        case employeeTextField:
            output.didTapSelectEmployee()
        default:
            break
        }
    }
}

// MARK: - Private

private extension EditTaskViewController {
    func fieldType(for textField: UITextField) -> EditTaskFieldType? {
        switch textField {
        case taskNameTextField:
            return .taskName
        case projectTextField:
            return .project
        case workTimeTextField:
            return .workTime
        case startDateTextField:
            return .startDate
        case endDateTextField:
            return .endDate
        case employeeTextField:
            return .employee
        default:
            return nil
        }
    }
    
    func setupView() {
        setupEditView()
        setupTextFields()
        setupToolbar()
        setupActions()
    }
    
    func setupEditView() {
        taskEditView.addRow(labelText: Localized.nameLabel, inputView: taskNameTextField)
        taskEditView.addRow(labelText: Localized.projectLabel, inputView: projectTextField)
        taskEditView.addRow(labelText: Localized.hoursLabel, inputView: workTimeTextField)
        taskEditView.addRow(labelText: Localized.startDateLabel, inputView: startDateTextField)
        taskEditView.addRow(labelText: Localized.endDateLabel, inputView: endDateTextField)
        taskEditView.addRow(labelText: Localized.statusLabel, inputView: statusSegmentedControl)
        taskEditView.addRow(labelText: Localized.employeeLabel, inputView: employeeHorizontalStack)
        
        view.addSubview(taskEditView)
        
        NSLayoutConstraint.activate([
            taskEditView.topAnchor.constraint(equalTo: view.topAnchor),
            taskEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupTextFields() {
        workTimeTextField.keyboardType = .numberPad
        
        startDateTextField.text = DateHelper.string(from: Date())
        startDateTextField.inputView = startDatePicker
        startDateTextField.inputAccessoryView = toolbar
        startDateTextField.delegate = self
    
        endDateTextField.inputView = endDatePicker
        endDateTextField.inputAccessoryView = toolbar
        endDateTextField.delegate = self

        taskNameTextField.delegate = self
        projectTextField.delegate = self
        workTimeTextField.delegate = self
        employeeTextField.delegate = self
    }
 
    func setupToolbar() {
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: Localized.select, style: .done, target: self, action: #selector(actionDateChange))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Localized.cancel, style: .plain, target: self, action: #selector(actionEndEditing))
    
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
    }
    
    func setupActions() {
        taskNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        projectTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        workTimeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        clearEmployeeButton.addTarget(self, action: #selector(actionClearEmployee), for: .touchUpInside)
    }
    
    @objc func actionSaveTask() {
        let taskNameString = taskNameTextField.text.unwrappedOrEmpty.trimmed
        let startDateString = startDateTextField.text.unwrappedOrEmpty.trimmed
        let endDateString = endDateTextField.text.unwrappedOrEmpty.trimmed
        let workTime = workTimeTextField.text.unwrappedOrEmpty.withoutSpaces
        
        output.didTapSaveButton (
            taskNameString: taskNameString,
            workTime: workTime,
            startDateString: startDateString,
            endDateString: endDateString,
            statusIndex: statusSegmentedControl.selectedSegmentIndex
        )
    }
    
    @objc func actionDateChange(_ sender: UIDatePicker) {
        if startDateTextField.isFirstResponder {
            let dateString = DateHelper.string(from: startDatePicker.date)
            startDateTextField.text = dateString
        } else if endDateTextField.isFirstResponder {
            let dateString = DateHelper.string(from: endDatePicker.date)
            endDateTextField.text = dateString
        }
        
        actionEndEditing()
    }
    
    @objc func actionClearEmployee() {
        employeeTextField.text = nil
        output.didTapClearEmployee()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let fieldType = fieldType(for: textField) else {
            return
        }
        output.textFieldDidChange(textFieldType: fieldType, text: textField.text)
    }
}
