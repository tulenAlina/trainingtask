import Foundation

enum TaskStatus: String, CaseIterable {
    case notStarted = "not_started"
    case inProgress = "in_progress"
    case completed = "completed"
    case postponed = "postponed"
    
    var localized: String {
        return self.rawValue.localized
    }
}

enum EditTaskAction {
    case create((ProjectTask) -> Void)
    case update((ProjectTask) -> Void)
}

struct ProjectTask {
    let id: UUID
    let createdAt: Date
    let taskName: String
    let projectID: UUID
    let workTime: Int
    let startDate: Date
    let endDate: Date
    let status: TaskStatus
    let employeeID: UUID?
    
    init(id: UUID = UUID(), taskName: String, projectID: UUID, workTime: Int, startDate: Date, endDate: Date, status: TaskStatus, employeeID: UUID? = nil, createdAt: Date = Date()) {
        self.id = id
        self.taskName = taskName
        self.projectID = projectID
        self.workTime = workTime
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.employeeID = employeeID
        self.createdAt = createdAt
    }
}
