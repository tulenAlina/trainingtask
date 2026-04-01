import UIKit

protocol FormValidatable {
    var isFieldsChanged: Bool { get }
    var isFormFilled: Bool { get }
    var isFormValid: Bool { get }
}

extension FormValidatable {
    var isFormValid: Bool {
        isFieldsChanged && isFormFilled
    }
}
