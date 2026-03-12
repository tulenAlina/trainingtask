import Foundation

struct TaskEntity {
    let id: UUID
    var taskName: String
    var projectID: UUID
    var workTime: Int
    var startDate: Date
    var endDate: Date
    var status: TaskStatus
    var employeeID: UUID
    
    init(id: UUID = UUID(), taskName: String, projectID: UUID, workTime: Int, startDate: Date, endDate: Date, status: TaskStatus, employeeID: UUID) {
        self.id = id
        self.taskName = taskName
        self.projectID = projectID
        self.workTime = workTime
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.employeeID = employeeID
    }
}

enum TaskStatus: String {
    case notStarted = "Не начата"
    case inProgress = "В процессе"
    case completed = "Завершена"
    case postponed = "Отложена"
}
