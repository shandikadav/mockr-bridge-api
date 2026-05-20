import Foundation

public struct GeminiGenerateRequest: Codable, Sendable {
    public let contents: [GeminiContent]
    public let systemInstruction: GeminiContent?
    public let generationConfig: GeminiGenerationConfig?

    public init(
        contents: [GeminiContent],
        systemInstruction: GeminiContent? = nil,
        generationConfig: GeminiGenerationConfig? = nil
    ) {
        self.contents = contents
        self.systemInstruction = systemInstruction
        self.generationConfig = generationConfig
    }
}

public struct GeminiContent: Codable, Sendable {
    public let role: String?
    public let parts: [GeminiPart]

    public init(role: String? = nil, parts: [GeminiPart]) {
        self.role = role
        self.parts = parts
    }

    public static func user(_ text: String) -> GeminiContent {
        GeminiContent(role: "user", parts: [GeminiPart(text: text)])
    }

    public static func model(_ text: String) -> GeminiContent {
        GeminiContent(role: "model", parts: [GeminiPart(text: text)])
    }
}

public struct GeminiPart: Codable, Sendable {
    public let text: String

    public init(text: String) {
        self.text = text
    }
}

public struct GeminiGenerationConfig: Codable, Sendable {
    public let temperature: Double?
    public let maxOutputTokens: Int?
    public let topP: Double?
    public let topK: Int?

    public init(
        temperature: Double? = nil,
        maxOutputTokens: Int? = nil,
        topP: Double? = nil,
        topK: Int? = nil
    ) {
        self.temperature = temperature
        self.maxOutputTokens = maxOutputTokens
        self.topP = topP
        self.topK = topK
    }
}

public struct GeminiCountTokensRequest: Codable, Sendable {
    public let contents: [GeminiContent]

    public init(contents: [GeminiContent]) {
        self.contents = contents
    }
}

public struct GeminiChatMessage: Codable, Sendable {
    public let role: String
    public let text: String

    public init(role: String, text: String) {
        self.role = role
        self.text = text
    }

    public static func user(_ text: String) -> GeminiChatMessage {
        GeminiChatMessage(role: "user", text: text)
    }

    public static func assistant(_ text: String) -> GeminiChatMessage {
        GeminiChatMessage(role: "model", text: text)
    }
}
