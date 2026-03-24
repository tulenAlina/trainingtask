import Foundation

struct ProjectEntity {
    let id: UUID
    var projectName: String
    var description: String
    var tasks: [UUID]
    let createdAt: Date
    
    init(id: UUID = UUID(), projectName: String, description: String, tasks: [UUID] = [], createdAt: Date = Date()) {
        self.id = id
        self.projectName = projectName
        self.description = description
        self.tasks = tasks
        self.createdAt = createdAt
    }
}
