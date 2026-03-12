import Foundation

struct Project {
    let id: UUID
    let projectName: String
    let description: String
    var tasks: [UUID]?
}
