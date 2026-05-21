import Vapor

/// Supported recap types.
enum RecapType: String, Content, CaseIterable {
    case daily
    case weekly
}

/// Response model for GET /api/v1/recap
struct RecapResponse: Content {
    let type: String
    let recap: String
    let generatedAt: String
}
