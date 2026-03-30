import Foundation

enum Localized {
    
    enum Alert {
        static let title = "alert_title"
        static let ok = "ok"
        static let error = "error"
        static let success = "success"
        static let warning = "warning"
    }
    
    enum Screen {
        static let projects = "projects"
        static let tasks = "tasks"
        static let employees = "employees"
        static let settings = "settings"
        static let appName = "app_name"
        static let addProject = "add_project"
        static let editProject = "edit_project"
        static let addTask = "add_task"
        static let editTask = "edit_task"
        static let addEmployee = "add_employee"
        static let editEmployee = "edit_employee"
        static let taskDetails = "task_details"
        static let employeeDetails = "employee_details"
        static let projectDetails = "project_details"
        static let mainMenu = "main_menu"
    }
    
    enum Action {
        static let save = "save"
        static let cancel = "cancel"
        static let clear = "clear"
        static let delete = "delete"
        static let edit = "edit"
        static let add = "add"
        static let refresh = "refresh"
        static let select = "select"
        static let change = "change"
        static let done = "done"
        static let openTasks = "open_tasks"
    }
    
    enum Status {
        static let notStarted = "not_started"
        static let inProgress = "in_progress"
        static let completed = "completed"
        static let postponed = "postponed"
    }
    
    enum Placeholder {
        static let taskName = "task_name_placeholder"
        static let selectedProjectName = "select_project_placeholder"
        static let projectName = "project_name_placeholder"
        static let projectDescription = "project_description_placeholder"
        static let workTime = "work_time_placeholder"
        static let startDate = "start_date_placeholder"
        static let endDate = "end_date_placeholder"
        static let employeeName = "employee_name_placeholder"
        static let firstName = "first_name_placeholder"
        static let lastName = "last_name_placeholder"
        static let surname = "surname_placeholder"
        static let position = "position_placeholder"
        static let serverUrl = "server_url_placeholder"
        static let maxRecords = "max_records_placeholder"
        static let defaultDaysBetween = "default_days_between_placeholder"
        static let name = "name_placeholder"
        static let description = "description_placeholder"
    }
    
    enum Label {
        static let name = "name_label"
        static let description = "description_label"
        static let firstName = "first_name_label"
        static let lastName = "last_name_label"
        static let surname = "surname_label"
        static let patronymic = "patronymic_label"
        static let position = "position_label"
        static let task = "task_label"
        static let project = "project_label"
        static let hours = "hours_label"
        static let startDate = "start_date_label"
        static let endDate = "end_date_label"
        static let employee = "employee_label"
        static let status = "status_label"
        static let serverUrl = "server_url_label"
        static let maxRecords = "max_records_label"
        static let defaultDaysBetween = "default_days_between_label"
        static let notAssigned = "not_assigned"
        static let unknownProject = "unknown_project"
        static let no = "no"
    }
    
    enum Empty {
        static let noProjects = "no_projects"
        static let noTasks = "no_tasks"
        static let noEmployees = "no_employees"
    }
    
    enum Error {
        static let title = "error_title"
        static let loadFailed = "load_failed"
        static let saveFailed = "save_failed"
        static let deleteFailed = "delete_failed"
        static let invalidDate = "invalid_date"
        static let invalidHours = "invalid_hours"
        static let selectProject = "select_project"
        static let selectEmployee = "select_employee"
        static let fillAllFields = "fill_all_fields"
        static let dateEndBeforeStart = "date_end_before_start"
        static let maxRecordsReached = "max_records_reached"
    }
    
    enum Confirmation {
        static let deleteProject = "delete_project_confirmation"
        static let deleteTask = "delete_task_confirmation"
        static let deleteEmployee = "delete_employee_confirmation"
    }
    
    enum Splash {
        static let version = "version_prefix"
    }
}
