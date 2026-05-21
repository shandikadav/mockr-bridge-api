import Vapor

func routes(_ app: Application) throws {
    // Landing page
    app.get { req async throws -> Response in
        return try await req.fileio.asyncStreamFile(
            at: app.directory.publicDirectory + "index.html"
        )
    }

    // API v1
    let v1 = app.grouped("api", "v1")
    try v1.register(collection: ChatController())
    try v1.register(collection: FeedbackController())
    try v1.register(collection: RecapController())
    try v1.register(collection: ContextController())
}
