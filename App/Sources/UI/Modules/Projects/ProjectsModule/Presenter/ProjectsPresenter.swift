import Foundation

final class ProjectsPresenter: ProjectsModuleInputProtocol {
    weak var view: ProjectsViewInputProtocol?
    private let interactor: ProjectsInteractorInputProtocol
    private var router: ProjectsRouterInputProtocol
    
    private var projects: [Project] = []
    
    init(interactor: ProjectsInteractorInputProtocol, router: ProjectsRouterInputProtocol) {
        self.interactor = interactor
        self.router = router
    }
}

// MARK: - ProjectsViewOutputProtocol

extension ProjectsPresenter: ProjectsViewOutputProtocol {
    func viewDidLoad() {
        view?.startLoading()
        refreshData()
    }
    
    func didRefreshData() {
        refreshData()
    }
    
    func didTapProjectRow(project: Project) {
        router.pushDetailScreen(for: project, moduleOutput: self)
    }
    
    func didTapAddButton() {
        router.pushAddProjectScreen(moduleOutput: self)
    }
}

// MARK: - EditProjectModuleOutputProtocol

extension ProjectsPresenter: EditProjectModuleOutputProtocol {
    func didCreateProject(_ project: Project) {
        view?.addItem(project)
    }
    
    func didUpdateProject(_ project: Project) {
        view?.updateItem(project) { $0.id == project.id }
    }
}

// MARK: - ProjectDetailModuleOutputProtocol

extension ProjectsPresenter: ProjectDetailModuleOutputProtocol {
    func didDeleteProject(with projectID: UUID) {
        deleteProject(with: projectID)
    }
}

// MARK: - Private

private extension ProjectsPresenter {
    func loadData() async throws {
        projects = try await interactor.fetchProjects()
        view?.setItems(projects)
    }
    
    func refreshData() {
        Task {
            do {
                try await loadData()
                await MainActor.run {
                    view?.updateUI()
                }
            } catch {
                await MainActor.run {
                    view?.stopLoading()
                    view?.endRefreshing()
                    view?.showAlert(Localized.loadFailed)
                }
            }
        }
    }
    
    func deleteProject(with projectID: UUID) {
        view?.startLoading()
        guard let index = view?.firstIndex(where: { $0.id == projectID }) else { return }

        Task {
            do {
                try await interactor.deleteProject(projectID)
                await MainActor.run {
                    view?.deleteItem(at: index)
                    view?.updateUI()
                }
            } catch {
                await MainActor.run {
                    view?.stopLoading()
                    view?.showAlert(Localized.deleteFailed)
                }
            }
        }
    }
}
