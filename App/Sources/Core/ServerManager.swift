final class ServerManager {
    static let shared = ServerManager()
    private let server: Server = StubServer()
    private init() {}
    var currentServer: Server {
        return server
    }
}
