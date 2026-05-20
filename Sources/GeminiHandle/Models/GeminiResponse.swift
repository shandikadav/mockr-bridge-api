import Foundation

public struct GeminiGenerateResponse: Codable, Sendable {
    public let candidates: [GeminiCandidate]?
    public let usageMetadata: GeminiUsageMetadata?
    public let promptFeedback: GeminiPromptFeedback?
}

public struct GeminiCandidate: Codable, Sendable {
    public let content: GeminiContent?
    public let finishReason: String?
    public let index: Int?
    public let safetyRatings: [GeminiSafetyRating]?
}

public struct GeminiUsageMetadata: Codable, Sendable {
    public let promptTokenCount: Int?
    public let candidatesTokenCount: Int?
    public let totalTokenCount: Int?
}

public struct GeminiPromptFeedback: Codable, Sendable {
    public let blockReason: String?
    public let safetyRatings: [GeminiSafetyRating]?
}

public struct GeminiSafetyRating: Codable, Sendable {
    public let category: String?
    public let probability: String?
}

public struct GeminiCountTokensResponse: Codable, Sendable {
    public let totalTokens: Int?
}

public struct GeminiStreamChunk: Codable, Sendable {
    public let text: String
    public let finishReason: String?
}
