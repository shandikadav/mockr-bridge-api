import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws -> Response in
        return try await req.fileio.asyncStreamFile(
            at: app.directory.publicDirectory + "index.html"
        )
    }

    try app.register(collection: ChatController())
}
