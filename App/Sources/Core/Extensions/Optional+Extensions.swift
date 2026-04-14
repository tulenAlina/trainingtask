extension Optional where Wrapped == String {
    var unwrappedOrEmpty: String {
        return self ?? ""
    }
}
