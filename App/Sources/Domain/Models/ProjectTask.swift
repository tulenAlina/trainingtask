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

struct ProjectTask {
    let id: UUID
    let createdAt: Date
    var taskName: String
    var projectID: UUID
    var workTime: Int
    var startDate: Date
    var endDate: Date
    var status: TaskStatus
    var employeeID: UUID?
    
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
