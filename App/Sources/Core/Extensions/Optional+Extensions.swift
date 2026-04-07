extension Optional where Wrapped == String {
    var orEmpty: String {
        return self ?? ""
    }
}
