import Vapor

/// Handles GET /api/v1/recap?type=(daily|weekly)
/// Returns the latest AI-generated recap from the context store.
struct RecapController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("recap", use: getRecap)
    }

    @Sendable
    func getRecap(req: Request) async throws -> APIResponse<RecapResponse> {
        guard let typeString: String = req.query["type"] else {
            throw Abort(
                .badRequest,
                reason: "Missing required query parameter 'type'. Use ?type=daily or ?type=weekly."
            )
        }

        guard let recapType = RecapType(rawValue: typeString.lowercased()) else {
            let validTypes = RecapType.allCases.map(\.rawValue).joined(separator: ", ")
            throw Abort(
                .badRequest,
                reason: "Invalid recap type '\(typeString)'. Valid types: \(validTypes)."
            )
        }

        guard let recap = await req.contextStore.getRecap(type: recapType) else {
            throw Abort(
                .notFound,
                reason: "No \(recapType.rawValue) recap available. POST context data to /api/v1/get-context first."
            )
        }

        return .success(recap)
    }
}
