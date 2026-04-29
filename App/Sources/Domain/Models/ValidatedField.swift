import UIKit

struct ValidatedField<FieldType: Hashable> {
    let textField: UITextField
    let isValid: Bool
}
