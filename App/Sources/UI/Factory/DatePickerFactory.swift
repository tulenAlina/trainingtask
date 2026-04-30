import UIKit

enum DatePickerFactory {
    static func createDatePicker() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.locale = Locale.current
        return picker
    }
}
