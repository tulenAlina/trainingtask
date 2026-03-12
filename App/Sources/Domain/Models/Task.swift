import Foundation

struct Task {
    let id: UUID
    let taskName: String
    let projectID: UUID
    let workTime: Int
    let startDate: Date = Date()
    let endDate: Date = Date() // поменять на старт + количество дней между датами
    let status: TaskStatus = .notStarted
    let employeeID: UUID
}

enum TaskStatus: String {
    case notStarted = "Не начата"
    case inProgress = "В процессе"
    case completed = "Завершена"
    case postponed = "Отложена"
}
