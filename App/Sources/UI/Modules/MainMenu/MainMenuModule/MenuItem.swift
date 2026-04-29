enum MenuItem: Int, CaseIterable {
    case projects
    case tasks
    case employees
    case settings
    
    var title: String {
        switch self {
            
        case .projects: return Localized.projects
        case .tasks: return Localized.tasks
        case .employees: return Localized.employees
        case .settings: return Localized.settings
        }
    }
}
