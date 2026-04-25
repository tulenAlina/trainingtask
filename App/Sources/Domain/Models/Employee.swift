import Foundation

enum EditEmployeeActionType {
    case create
    case update
}

struct Employee {
    let id: UUID
    let createdAt: Date
    let firstName: String
    let lastName: String
    let surName: String?
    let position: String
    let tasks: [UUID]
    
    var fullName: String {
        [lastName, firstName, surName]
            .compactMap { $0 }
            .joined(separator: " ")
            .trimmed
    }
    
    init(id: UUID = UUID(), firstName: String, lastName: String, surName: String? = nil, position: String, tasks: [UUID] = [], createdAt: Date = Date()) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.surName = surName
        self.position = position
        self.tasks = tasks
        self.createdAt = createdAt
    }
}
