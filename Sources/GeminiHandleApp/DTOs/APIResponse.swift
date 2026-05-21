import Vapor

/// Generic API response wrapper for consistent endpoint responses.
struct APIResponse<T: Content>: Content {
    let success: Bool
    let message: String?
    let data: T?

    /// Create a success response with data.
    static func success(_ data: T, message: String? = nil) -> APIResponse<T> {
        APIResponse(success: true, message: message, data: data)
    }

    /// Create a success response without data.
    static func ok(message: String) -> APIResponse<T> {
        APIResponse(success: true, message: message, data: nil)
    }
}

/// Empty content type for responses with no data payload.
struct EmptyData: Content {}

extension APIResponse where T == EmptyData {
    /// Create an error response with no data.
    static func error(message: String) -> APIResponse<EmptyData> {
        APIResponse<EmptyData>(success: false, message: message, data: nil)
    }
}
