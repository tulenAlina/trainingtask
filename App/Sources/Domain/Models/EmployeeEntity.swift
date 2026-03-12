import Foundation

struct EmployeeEntity {
    let id: UUID
    var firstName: String
    var lastName: String
    var surName: String?
    var position: String
    var tasks: [UUID] = []
    
    init(id: UUID = UUID(), firstName: String, lastName: String, surName: String? = nil, position: String, tasks: [UUID] = []) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.surName = surName
        self.position = position
        self.tasks = tasks
    }
}
