import UIKit

protocol EditTaskViewProtocol: AnyObject {
    var presenter: EditTaskPresenterProtocol { get set }
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

final class EditTaskViewController: BaseViewController {
    var presenter: EditTaskPresenterProtocol
    
    private let toolbar = UIToolbar()
    private let taskEditView = EditView()
    
    private var taskNameTextField = UIFactory.createDefaultTextField(placeholder: Localized.taskNamePlaceholder)
    private var projectTextField = UIFactory.createDefaultTextField(placeholder: Localized.selectedProjectNamePlaceholder)
    private var workTimeTextField = UIFactory.createDefaultTextField(placeholder: Localized.workTimePlaceholder)
    private var startDateTextField = UIFactory.createDefaultTextField(placeholder: Localized.startDatePlaceholder)
    private var endDateTextField = UIFactory.createDefaultTextField(placeholder: Localized.endDatePlaceholder)
    private var employeeTextField = UIFactory.createDefaultTextField(placeholder: Localized.employeeNamePlaceholder)
    
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
    
    private lazy var employeeHorizontalStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [employeeTextField, clearEmployeeButton])
        stack.axis = .horizontal
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    init(presenter: EditTaskPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    private func setupUI() {
        setupEditView()
        setupTextFields()
        setupClearEmployeeButton()
        setupToolbar()
    }
    
    private func setupEditView() {
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
        
        taskNameTextField.addTarget(taskEditView, action: #selector(taskEditView.textFieldDidChange), for: .editingChanged)
        projectTextField.addTarget(taskEditView, action: #selector(taskEditView.textFieldDidChange), for: .editingChanged)
        workTimeTextField.addTarget(taskEditView, action: #selector(taskEditView.textFieldDidChange), for: .editingChanged)
    }
    
    private func setupClearEmployeeButton() {
        clearEmployeeButton.addTarget(self, action: #selector(actionClearEmployee), for: .touchUpInside)
        clearEmployeeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
    }
 
    private func setupToolbar() {
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Выбрать", style: .done, target: self, action: #selector(actionDateChange))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(actionEndEditing))
    
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
    }
    
    @objc private func actionSaveTask() {
        
        let taskNameString = taskNameTextField.text.unwrappedOrEmpty.trimmed
        let startDateString = startDateTextField.text.unwrappedOrEmpty.trimmed
        let endDateString = endDateTextField.text.unwrappedOrEmpty.trimmed
        let workTime = workTimeTextField.text.unwrappedOrEmpty.withoutSpaces
        
        presenter.didTapSaveButton (
            taskNameString: taskNameString,
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
        presenter.didTapClearEmployee()
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
            presenter.didTapSelectProject()
        case employeeTextField:
            presenter.didTapSelectEmployee()
        default:
            break
        }
    }
}

extension EditTaskViewController: EditTaskViewProtocol {
    var requiredFields: [UITextField] {
        return [taskNameTextField, projectTextField, workTimeTextField]
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
