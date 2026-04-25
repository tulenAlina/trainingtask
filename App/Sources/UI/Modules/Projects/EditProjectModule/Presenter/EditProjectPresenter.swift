import Foundation

final class EditProjectPresenter: EditProjectModuleInputProtocol {
    weak var view: EditProjectViewInputProtocol?
    weak var output: EditProjectModuleOutputProtocol?
    private let interactor: EditProjectInteractorInputProtocol
    private var router: EditProjectRouterInputProtocol
    
    private var action: EditProjectActionType = .create
    private var project: Project?
    
    init(interactor: EditProjectInteractorInputProtocol, router: EditProjectRouterInputProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    func createProject() {
        self.project = nil
        self.action = .create
    }
    
    func updateProject(project: Project) {
        self.project = project
        self.action = .update
    }
}

// MARK: - EditProjectViewOutputProtocol

extension EditProjectPresenter: EditProjectViewOutputProtocol {
    func viewDidLoad() {
        let title = (project != nil) ? Localized.editProject : Localized.addProject
        configureFields()
        view?.setupNavigationBar(title: title)
    }
    
    func didTapSaveButton(name: String, description: String) {
        guard validateProject(name: name, description: description) else {
            return
        }
        
        guard isFieldsChanged(name: name, description: description) else {
            router.close()
            return
        }
        
        saveProject(name: name, description: description)
    }
    
    func textFieldDidChange(textFieldType: EditProjectFieldType,text: String?) {
        if text?.isBlank == false {
            view?.updateValidationStyle(textFieldType: textFieldType, isValid: true)
        } else {
            view?.updateValidationStyle(textFieldType: textFieldType, isValid: false)
        }
    }
}

// MARK: - Private

private extension EditProjectPresenter {
    func isFieldsChanged(name: String, description: String) -> Bool {
        guard let project else {
            return true
        }
        
        let isNameChanged = name != project.projectName.trimmed
        let isDescriptionChanged = description != project.description.trimmed
        return isNameChanged || isDescriptionChanged
    }
    
    func configureFields() {
        if let project {
            let name = project.projectName
            let description = project.description
        
            view?.setProjectFields(
                name: name,
                description: description
            )
        }
    }
    
    func createProject(
        from existingProject: Project? = nil,
        name: String,
        description: String
    ) -> Project {
        if let existingProject {
            return Project(
                id: existingProject.id,
                projectName: name,
                description: description,
                createdAt: existingProject.createdAt
            )
        } else {
            return Project(
                projectName: name,
                description: description,
            )
        }
    }
    
    func saveProject(name: String, description: String) {
        view?.startLoading()
        Task {
            do {
                let newProject = createProject(from: project, name: name, description: description)
                project != nil ? try await interactor.updateProject(newProject) : try await interactor.createProject(newProject)

                await MainActor.run {
                    switch self.action {
                    case .create:
                        output?.didCreateProject(newProject)
                    case .update:
                        output?.didUpdateProject(newProject)
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

    func validateFields(name: String, description: String) -> Bool {
        guard let view else {
            return false
        }
        var fieldsValidity: [Bool] = []
        var isValid = true
        
        for text in [name, description] {
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
    
    func validateProject(name: String, description: String) -> Bool {
        guard validateFields(name: name, description: description) else {
            view?.showAlert(Localized.emptyFields)
            return false
        }
        return true
    }
}
