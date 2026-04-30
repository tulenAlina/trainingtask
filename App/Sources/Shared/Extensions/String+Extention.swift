import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var withoutSpaces: String {
        replacingOccurrences(of: " ", with: "")
    }
    
    var cleanedInt: Int {
        Int(withoutSpaces.trimmed) ?? 0
    }
    
    var isBlank: Bool {
        trimmed.isEmpty
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
