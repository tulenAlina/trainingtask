import Foundation

struct Employee {
    let id: UUID
    let firstName: String
    let lastName: String
    let surName: String?
    let position: String
    var tasks: [UUID]?
}
