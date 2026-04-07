import Foundation

struct Project {
    let id: UUID
    let createdAt: Date
    let projectName: String
    let description: String
    let tasks: [UUID]
    
    init(id: UUID = UUID(), projectName: String, description: String, tasks: [UUID] = [], createdAt: Date = Date()) {
        self.id = id
        self.projectName = projectName
        self.description = description
        self.tasks = tasks
        self.createdAt = createdAt
    }
}
