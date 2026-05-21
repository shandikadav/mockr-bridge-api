import Vapor

// MARK: - Request

/// Request body for POST /api/v1/get-context
struct ContextRequest: Content {
    let entries: [ContextEntry]
}

/// Individual context entry from the client app.
struct ContextEntry: Content {
    let category: String
    let title: String
    let value: String
    let date: String?
}

// MARK: - Stored Data

/// Stored context data with metadata.
struct ContextData: Content {
    let entries: [ContextEntry]
    let updatedAt: String
}

// MARK: - Response

/// Response returned after processing context.
struct ContextResponse: Content {
    let feedback: String
    let dailyRecap: String
    let weeklyRecap: String
    let updatedAt: String
}
