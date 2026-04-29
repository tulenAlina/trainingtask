import Foundation

/// Протокол для работы с серверным API
/// Определяет все операции для управления проектами, сотрудниками и задачами
protocol Server {
    // MARK: - Projects
    
    /// Загрузить проекты
    /// - Returns: Список проектов
    func loadProjects() async throws -> [Project]
    
    /// Создать проект
    /// - Parameter project: Создаваемый проект
    func createProject(_ project: Project) async throws
    
    /// Обновить проект
    /// - Parameter project: Обновляемый проект
    func updateProject(_ project: Project) async throws
    
    /// Удалить проект
    /// - Parameter id: ID удаляемого проекта
    func deleteProject(_ id: UUID) async throws
    
    // MARK: - Employees
    
    /// Загрузить сотрудников
    /// - Returns: Список сотрудников
    func loadEmployees() async throws -> [Employee]
    
    /// Создать сотрудника
    /// - Parameter employee: Создаваемый сотрудник
    func createEmployee(_ employee: Employee) async throws
    
    /// Обновить сотрудника
    /// - Parameter employee: Обновляемый сотрудник
    func updateEmployee(_ employee: Employee) async throws
    
    /// Удалить сотрудника
    /// - Parameter id: ID удаляемого сотрудника.
    func deleteEmployee(_ id: UUID) async throws
    
    // MARK: - Tasks
    
    /// Загрузить задачи
    /// - Parameter projectID: ID проекта
    /// - Returns: Список задач
    func loadTasks(projectID: UUID?) async throws -> [ProjectTask]
    
    /// Создать задачу
    /// - Parameter task: Создаваемая задача
    func createTask(_ task: ProjectTask) async throws
    
    /// Обновить задачу
    /// - Parameter task: Обновляемая задача
    func updateTask(_ task: ProjectTask) async throws
    
    /// Удалить задачу
    /// - Parameter id: ID удаляемой задачи
    func deleteTask(_ id: UUID) async throws
}
