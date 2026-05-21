import Vapor

/// Handles GET /api/v1/feedback
/// Returns the latest AI-generated feedback from the context store.
struct FeedbackController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("feedback", use: getFeedback)
    }

    @Sendable
    func getFeedback(req: Request) async throws -> APIResponse<FeedbackResponse> {
        guard let feedback = await req.contextStore.getFeedback() else {
            throw Abort(
                .notFound,
                reason: "No feedback available. POST context data to /api/v1/get-context first."
            )
        }

        return .success(feedback)
    }
}
