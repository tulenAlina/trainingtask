import UIKit

/// Протокол для обновления проекта
/// Используется в `EditProjectViewController` и `ProjectDetailViewController` для уведомления об обновлении
protocol ProjectUpdateDelegate: AnyObject {
    /// Вызывается после успешного обновления проекта
    /// - Parameter project: Обновлённый проект
    func didUpdateProject(_ project: Project)
}

/// Протокол для создания проекта
/// Используется в `EditProjectViewController` для уведомления о создании нового проекта
protocol ProjectCreateDelegate: AnyObject {
    /// Вызывается после успешного создания проекта
    /// - Parameter project: Созданный проект
    func didCreateProject(_ project: Project)
}

/// Протокол для удаления проекта
/// Используется в `ProjectDetailViewController` для уведомления об удалении
protocol ProjectDeleteDelegate: AnyObject {
    /// Вызывается при удалении проекта
    /// - Parameters:
    ///   - project: Удаляемый проект
    ///   - indexPath: Индекс проекта в списке для обновления UI
    func didDeleteProject(_ project: Project, at indexPath: IndexPath)
}

/// Протокол для обновления задачи
/// Используется в `EditTaskViewController` и `TaskDetailViewController` для уведомления об обновлении
protocol TaskUpdateDelegate: AnyObject {
    /// Вызывается после успешного обновления задачи
    /// - Parameter task: Обновлённая задача
    func didUpdateTask(_ task: ProjectTask)
}

/// Протокол для создания задачи
/// Используется в `EditTaskViewController` для уведомления о создании новой задачи
protocol TaskCreateDelegate: AnyObject {
    /// Вызывается после успешного создания задачи
    /// - Parameter task: Созданная задача
    func didCreateTask(_ task: ProjectTask)
}

/// Протокол для удаления задачи
/// Используется в `TaskDetailViewController` для уведомления об удалении
protocol TaskDeleteDelegate: AnyObject {
    /// Вызывается при удалении задачи
    /// - Parameters:
    ///   - task: Удаляемая задача
    ///   - indexPath: Индекс задачи в списке для обновления UI
    func didDeleteTask(_ task: ProjectTask, at indexPath: IndexPath)
}

/// Протокол для обновления сотрудника
/// Используется в `EditEmployeeViewController` и `EmployeeDetailViewController` для уведомления об обновлении
protocol EmployeeUpdateDelegate: AnyObject {
    /// Вызывается после успешного обновления сотрудника
    /// - Parameter employee: Обновлённый сотрудник
    func didUpdateEmployee(_ employee: Employee)
}

/// Протокол для создания сотрудника
/// Используется в `EditEmployeeViewController` для уведомления о создании нового сотрудника
protocol EmployeeCreateDelegate: AnyObject {
    /// Вызывается после успешного создания сотрудника
    /// - Parameter employee: Созданный сотрудник
    func didCreateEmployee(_ employee: Employee)
}

/// Протокол для удаления сотрудника
/// Используется в `EmployeeDetailViewController` для уведомления об удалении
protocol EmployeeDeleteDelegate: AnyObject {
    /// Вызывается при удалении сотрудника
    /// - Parameters:
    ///   - employee: Удаляемый сотрудник
    ///   - indexPath: Индекс сотрудника в списке для обновления UI
    func didDeleteEmployee(_ employee: Employee, at indexPath: IndexPath)
}
