import UIKit

protocol EditTaskViewProtocol: BaseFormViewController {
    var presenter: EditTaskPresenterProtocol? { get set }
    func setupNavigationBar(title: String)
    func updateUI(projectName: String, employeeName: String?)
    func startLoading()
    func stopLoading()
    func updateProjectName(_ name: String)
    func updateEmployeeName(_ name: String)
    func setProjectField(text: String)
    func setEndDateField(defaultDaysBetween: Int)
    func setTaskFields(taskName: String, projectName: String, workTime: String, startDate: String, endDate: String, employee: String?)
    func setupSegmentedControl(index: Int)
}

final class EditTaskViewController2: BaseFormViewController, EditTaskViewProtocol {
    weak var presenter: EditTaskPresenterProtocol?
    
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
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    func setupNavigationBar(title: String) {
        super.setupNavigationBar(navigationTitle: title, rightButtonTitle: Localized.save, rightButtonAction: #selector(actionSaveTask))
    }
    
    private func setupUI() {
        setupTextFields()
        setupFormRows()
        setupClearEmployeeButton()
        setupToolbar()
        setupForm()
        
        stackView.isHidden = true
    }
    
    func setProjectField(text: String) {
        projectTextField.text = text
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
    
    private func setupTextFields() {        
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
        
        taskNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        projectTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        workTimeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupFormRows() {
        let taskNameRow = UIFactory.createFormRow(labelText: Localized.nameLabel, inputView: taskNameTextField)
        let projectRow = UIFactory.createFormRow(labelText: Localized.projectLabel, inputView: projectTextField)
        let workTimeRow = UIFactory.createFormRow(labelText: Localized.hoursLabel, inputView: workTimeTextField)
        let startDateRow = UIFactory.createFormRow(labelText: Localized.startDateLabel, inputView: startDateTextField)
        let endDateRow = UIFactory.createFormRow(labelText: Localized.endDateLabel, inputView: endDateTextField)
        let statusDateRow = UIFactory.createFormRow(labelText: Localized.statusLabel, inputView: statusSegmentedControl)
        
        let employeeHorizontalStack = UIStackView(arrangedSubviews: [employeeTextField, clearEmployeeButton])
        employeeHorizontalStack.axis = .horizontal
        employeeHorizontalStack.spacing = 5
        employeeHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let employeeRow = UIFactory.createFormRow(labelText: Localized.employeeLabel, inputView: employeeHorizontalStack)
        
        [taskNameRow, projectRow, workTimeRow, startDateRow, endDateRow, employeeRow, statusDateRow].forEach { row in
            stackView.addArrangedSubview(row)
        }
    }
    
    private func setupClearEmployeeButton() {
        clearEmployeeButton.addTarget(self, action: #selector(actionClearEmployee), for: .touchUpInside)
        clearEmployeeButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    func setupSegmentedControl(index: Int) {
        statusSegmentedControl.selectedSegmentIndex = index
    }
 
    private func setupToolbar() {
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(actionDateChange))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(actionEndEditing))
    
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
    }
    
    func updateUI(projectName: String, employeeName: String?) {
        projectTextField.text = projectName
        employeeTextField.text = employeeName
        stackView.isHidden = false
        stopLoading()
    }
    
    func updateProjectName(_ name: String) {
        projectTextField.text = name
        textFieldDidChange(sender: projectTextField)
    }
    
    func updateEmployeeName(_ name: String) {
        employeeTextField.text = name
    }
    
    @objc private func actionSaveTask() {
        
        let startDateString = startDateTextField.text.orEmpty.trimmed
        let endDateString = endDateTextField.text.orEmpty.trimmed
        let workTime = workTimeTextField.text.orEmpty.withoutSpaces.cleanedInt
        
        presenter?.didTapSaveButton (
            taskNameString: taskNameTextField.text.orEmpty.trimmed,
            workTime: workTime,
            startDateString: startDateString,
            endDateString: endDateString,
            statusIndex: statusSegmentedControl.selectedSegmentIndex
        )
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
    
    @objc private func actionClearEmployee() {
        employeeTextField.text = nil
        presenter?.didTapClearEmployee()
    }
}

extension EditTaskViewController2: UITextFieldDelegate {
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
            presenter?.didTapSelectProject()
        case employeeTextField:
            presenter?.didTapSelectEmployee()
        default:
            break
        }
    }
}
