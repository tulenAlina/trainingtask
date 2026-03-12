import Foundation

struct Task {
    let id: UUID
    let taskName: String
    let projectID: UUID
    let workTime: Int
    let startDate: Date
    let endDate: Date
    let status: TaskStatus
    let employeeID: UUID
}

enum TaskStatus: String {
    case notStarted = "Не начата"
    case inProgress = "В процессе"
    case completed = "Завершена"
    case postponed = "Отложена"
}
