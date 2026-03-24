import Foundation

struct EmployeeEntity {
    let id: UUID
    var firstName: String
    var lastName: String
    var surName: String?
    var position: String
    var tasks: [UUID] = []
    let createdAt: Date
    
    init(id: UUID = UUID(), firstName: String, lastName: String, surName: String? = nil, position: String, tasks: [UUID] = [], createdAt: Date = Date()) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.surName = surName
        self.position = position
        self.tasks = tasks
        self.createdAt = createdAt
    }
    
    var fullName: String {
        [lastName, firstName, surName]
            .compactMap { $0 }
            .joined(separator: " ")
            .trimmed
    }
}
