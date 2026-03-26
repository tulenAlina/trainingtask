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
        
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
}
