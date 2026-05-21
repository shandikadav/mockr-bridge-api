import Vapor

/// Response model for GET /api/v1/feedback
struct FeedbackResponse: Content {
    let feedback: String
    let generatedAt: String
}
