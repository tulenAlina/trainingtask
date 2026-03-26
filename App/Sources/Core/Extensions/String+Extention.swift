import Foundation

extension String {
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isBlank: Bool {
        trimmed.isEmpty
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
