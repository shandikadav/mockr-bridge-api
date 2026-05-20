import Vapor
import GeminiHandle

public func configure(_ app: Application) async throws {
    // Serve static files from the 'Public' directory
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try app.configureGemini()

    try routes(app)
}
