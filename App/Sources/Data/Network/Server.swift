import Foundation

/// Протокол для работы с серверным API
/// Определяет все операции для управления проектами, сотрудниками и задачами
protocol Server {
    // MARK: - Projects
        
    /// Загружает все проекты с сервера.
    /// - Returns: Массив проектов.
    func fetchProjects() async throws -> [Project]
    
    /// Создаёт новый проект на сервере.
    /// - Parameter project: Проект для создания.
    func createProject(_ project: Project) async throws
    
    /// Обновляет существующий проект на сервере.
    /// - Parameter project: Проект с обновлёнными полями.
    func updateProject(_ project: Project) async throws
    
    /// Удаляет проект с сервера.
    /// - Parameter id: UUID удаляемого проекта.
    func deleteProject(_ id: UUID) async throws
    
    // MARK: - Employees
    
    /// Загружает всех сотрудников с сервера.
    /// - Returns: Массив сотрудников.
    func fetchEmployees() async throws -> [Employee]
    
    /// Создаёт нового сотрудника на сервере.
    /// - Parameter employee: Сотрудник для создания.
    func createEmployee(_ employee: Employee) async throws
    
    /// Обновляет существующего сотрудника на сервере.
    /// - Parameter employee: Сотрудник с обновлёнными полями.
    func updateEmployee(_ employee: Employee) async throws
    
    /// Удаляет сотрудника с сервера.
    /// - Parameter id: UUID удаляемого сотрудника.
    func deleteEmployee(_ id: UUID) async throws
    
    // MARK: - Tasks
    
    /// Загружает задачи с сервера.
    /// - Parameter projectID: ID проекта для фильтрации. Если nil — загружаются все задачи.
    /// - Returns: Массив задач.
    func fetchTasks(projectID: UUID?) async throws -> [ProjectTask]
    
    /// Создаёт новую задачу на сервере.
    /// - Parameter task: Задача для создания.
    func createTask(_ task: ProjectTask) async throws
    
    /// Обновляет существующую задачу на сервере.
    /// - Parameter task: Задача с обновлёнными полями.
    func updateTask(_ task: ProjectTask) async throws
    
    /// Удаляет задачу с сервера.
    /// - Parameter id: UUID удаляемой задачи.
    func deleteTask(_ id: UUID) async throws
}
