import Foundation

final class EditEmployeePresenter: EditEmployeeModuleInputProtocol {
    weak var view: EditEmployeeViewInputProtocol?
    weak var output: EditEmployeeModuleOutputProtocol?
    private let interactor: EditEmployeeInteractorInputProtocol
    private var router: EditEmployeeRouterInputProtocol
    
    private var action: EditEmployeeActionType = .create
    private var employee: Employee?
    
    init(interactor: EditEmployeeInteractorInputProtocol, router: EditEmployeeRouterInputProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func createEmployee() {
        self.employee = nil
        self.action = .create
    }
    
    func updateEmployee(employee: Employee) {
        self.employee = employee
        self.action = .update
    }
}

// MARK: - EditEmployeeViewOutputProtocol
extension EditEmployeePresenter: EditEmployeeViewOutputProtocol {
    func viewDidLoad() {
        let title = (employee != nil) ? Localized.editEmployee : Localized.addEmployee
        configureFields()
        view?.setupNavigationBar(title: title)
    }
    
    func didTapSaveButton(firstName: String, lastName: String, surName: String?, position: String) {
        guard validateEmployee(firstName: firstName, lastName: lastName, position: position) else {
            return
        }
        
        guard isFieldsChanged(firstName: firstName, lastName: lastName, surName: surName, position: position) else {
            router.close()
            return
        }
        
        saveEmployee(firstName: firstName, lastName: lastName, surName: surName, position: position)
    }
    
    func textFieldDidChange(textFieldType: EditEmployeeFieldType,text: String?) {
        if text?.isBlank == false {
            view?.updateValidationStyle(textFieldType: textFieldType, isValid: true)
        } else {
            view?.updateValidationStyle(textFieldType: textFieldType, isValid: false)
        }
    }
}

// MARK: - Private
private extension EditEmployeePresenter {
    func isFieldsChanged(firstName: String, lastName: String, surName: String?, position: String) -> Bool {
        guard let employee else {
            return true
        }
        
        let isFirstNameChanged = firstName != employee.firstName.trimmed
        let isLastNameChanged = lastName != employee.lastName.trimmed
        let isSurNameChanged = surName != employee.surName.unwrappedOrEmpty.trimmed
        let isPositionChanged = position != employee.position.trimmed
        return isFirstNameChanged || isLastNameChanged || isSurNameChanged || isPositionChanged
    }
    
    func configureFields() {
        if let employee {
            let firstName = employee.firstName
            let lastName = employee.lastName
            let surName = employee.surName.unwrappedOrEmpty
            let position = employee.position
        
            view?.setEmployeeFields(
                firstName: firstName,
                lastName: lastName,
                surName: surName,
                position: position
            )
        }
    }
    
    func createEmployee(
        from existingEmployee: Employee? = nil,
        firstName: String,
        lastName: String,
        surName: String?,
        position: String
    ) -> Employee {
        if let existingEmployee {
            return Employee(
                id: existingEmployee.id,
                firstName: firstName,
                lastName: lastName,
                surName: surName,
                position: position,
                createdAt: existingEmployee.createdAt
            )
        } else {
            return Employee(
                firstName: firstName,
                lastName: lastName,
                surName: surName,
                position: position,
            )
        }
    }
    
    func saveEmployee(firstName: String, lastName: String, surName: String?, position: String) {
        view?.startLoading()
        Task {
            do {
                let newEmployee = createEmployee(from: employee, firstName: firstName, lastName: lastName, surName: surName, position: position)
                employee != nil ? try await interactor.updateEmployee(newEmployee) : try await interactor.createEmployee(newEmployee)

                await MainActor.run {
                    switch self.action {
                    case .create:
                        output?.didCreateEmployee(newEmployee)
                    case .update:
                        output?.didUpdateEmployee(newEmployee)
                                        }
                    view?.stopLoading()
                    router.close()
                }
            } catch {
                await MainActor.run {
                    view?.stopLoading()
                    view?.showAlert(Localized.saveFailed)
                }
            }
        }
    }

    func validateFields(firstName: String, lastName: String, position: String) -> Bool {
        guard let view else {
            return false
        }
        var fieldsValidity: [Bool] = []
        var isValid = true
        
        for text in [firstName, lastName, position] {
            if text.isBlank == true {
                fieldsValidity.append(false)
                isValid = false
            } else {
                fieldsValidity.append(true)
            }
        }
        view.applyValidationResults(fieldsValidity)
        return isValid
    }
    
    func validateEmployee(firstName: String, lastName: String, position: String) -> Bool {
        guard validateFields(firstName: firstName, lastName: lastName, position: position) else {
            view?.showAlert(Localized.emptyFields)
            return false
        }
        return true
    }
}
