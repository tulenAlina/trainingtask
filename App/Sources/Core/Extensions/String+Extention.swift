import Foundation

extension String {
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var withoutSpaces: String {
        return replacingOccurrences(of: " ", with: "")
    }
    
    var cleanedInt: Int {
        return Int(withoutSpaces.trimmed) ?? 0
    }
    
    var isBlank: Bool {
        trimmed.isEmpty
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
