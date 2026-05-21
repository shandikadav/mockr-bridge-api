import Vapor
import GeminiHandle

public func configure(_ app: Application) async throws {
    // Serve static files from the 'Public' directory
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Initialize services
    try app.configureGemini()
    app.initializeContextStore()

    // Register routes
    try routes(app)
}
