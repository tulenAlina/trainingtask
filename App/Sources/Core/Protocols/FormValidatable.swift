import UIKit

protocol FormValidatable {
    var saveButton: UIBarButtonItem! { get }
    var isFieldsChanged: Bool { get }
    var isFormFilled: Bool { get }
    var isFormValid: Bool { get }
}

extension FormValidatable {
    var isFormValid: Bool {
        isFieldsChanged && isFormFilled
    }
}
