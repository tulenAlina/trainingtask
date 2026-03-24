final class ServerManager {
    static let shared = ServerManager()
    var currentServer: Server {
        return server
    }
    private let server: Server = StubServer()
    private init() {}
}
