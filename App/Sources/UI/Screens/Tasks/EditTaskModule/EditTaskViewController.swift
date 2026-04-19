import UIKit

protocol EditTaskViewInputProtocol: AnyObject {
    var output: EditTaskViewOutputProtocol { get set }
    var requiredFields: [UITextField] { get }
    
    func setupNavigationBar(title: String)
    func setupSegmentedControl(index: Int)
    func updateProjectName(_ name: String)
    func updateEmployeeName(_ name: String)
    func setProjectField(projectName: String)
    func setEndDateField(defaultDaysBetween: Int)
    func setTaskFields(taskName: String, projectName: String, workTime: String, startDate: String, endDate: String, employee: String?)
    func applyValidationResults(_ fieldsValidity: [Bool])
    func startLoading()
    func stopLoading()
    func showAlert (_ message: String)
}

protocol EditTaskViewOutputProtocol {
    func viewDidLoad()
    func didTapSaveButton(taskNameString: String, workTime: String, startDateString: String, endDateString: String, statusIndex: Int)
    func didTapClearEmployee()
    func didTapSelectProject()
    func didTapSelectEmployee()
}

final class EditTaskViewController: BaseViewController, EditTaskViewInputProtocol {
    var output: EditTaskViewOutputProtocol
    
    var requiredFields: [UITextField] {
        return [taskNameTextField, projectTextField, workTimeTextField]
    }
    
    private let toolbar = UIToolbar()
    private let taskEditView = EditView()
    
    private let taskNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.taskNamePlaceholder)
    private let projectTextField = UIFactory.createDefaultTextField(placeholder: Localized.selectedProjectNamePlaceholder)
    private let workTimeTextField = UIFactory.createDefaultTextField(placeholder: Localized.workTimePlaceholder)
    private let startDateTextField = UIFactory.createDefaultTextField(placeholder: Localized.startDatePlaceholder)
    private let endDateTextField = UIFactory.createDefaultTextField(placeholder: Localized.endDatePlaceholder)
    private let employeeTextField = UIFactory.createDefaultTextField(placeholder: Localized.employeeNamePlaceholder)
    
    private let statusSegmentedControl = UIFactory.createSegmentedControl(items: TaskStatus.allCases.map {$0.rawValue.localized})
    
    private let startDatePicker = UIFactory.createDatePicker()
    private let endDatePicker = UIFactory.createDatePicker()
    private let clearEmployeeButton = UIFactory.createClearButton()
    
    private lazy var employeeHorizontalStack = UIFactory.createHorizontalStackView(views: [employeeTextField, clearEmployeeButton], spacing: 5)
    
    init(presenter: EditTaskViewOutputProtocol) {
        self.output = presenter
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
        taskEditView.textFieldDidChange(sender: projectTextField)
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
        var result: [(UITextField, Bool)] = []
        for i in 0..<requiredFields.count {
            result.append((requiredFields[i], fieldsValidity[i]))
        }
        taskEditView.applyValidationResults(result)
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
            output.didTapSelectProject()
        case employeeTextField:
            output.didTapSelectEmployee()
        default:
            break
        }
    }
}

private extension EditTaskViewController {
    func setupView() {
        setupEditView()
        setupTextFields()
        setupClearEmployeeButton()
        setupToolbar()
    }
    
    func setupEditView() {
        view.addSubview(taskEditView)
        taskEditView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskEditView.topAnchor.constraint(equalTo: view.topAnchor),
            taskEditView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            taskEditView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            taskEditView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let formRows: [(String, UIView)] = [
            (labelText: Localized.nameLabel, inputView: taskNameTextField),
            (labelText: Localized.projectLabel, inputView: projectTextField),
            (labelText: Localized.hoursLabel, inputView: workTimeTextField),
            (labelText: Localized.startDateLabel, inputView: startDateTextField),
            (labelText: Localized.endDateLabel, inputView: endDateTextField),
            (labelText: Localized.statusLabel, inputView: statusSegmentedControl),
            (labelText: Localized.employeeLabel, inputView: employeeHorizontalStack)
        ]
        
        taskEditView.setupForm(rows: formRows)
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
        
        taskNameTextField.addTarget(taskEditView, action: #selector(taskEditView.textFieldDidChange), for: .editingChanged)
        projectTextField.addTarget(taskEditView, action: #selector(taskEditView.textFieldDidChange), for: .editingChanged)
        workTimeTextField.addTarget(taskEditView, action: #selector(taskEditView.textFieldDidChange), for: .editingChanged)
    }
    
    func setupClearEmployeeButton() {
        clearEmployeeButton.addTarget(self, action: #selector(actionClearEmployee), for: .touchUpInside)
        clearEmployeeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
    }
 
    func setupToolbar() {
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: Localized.select, style: .done, target: self, action: #selector(actionDateChange))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Localized.cancel, style: .plain, target: self, action: #selector(actionEndEditing))
    
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
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
}
