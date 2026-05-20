import Vapor

public struct GeminiConfiguration: Sendable {
    public let apiKey: String
    public let model: String
    public let systemInstruction: String?
    public let generationConfig: GeminiGenerationConfig?

    public init(
        apiKey: String,
        model: String = "gemini-2.0-flash",
        systemInstruction: String? = nil,
        generationConfig: GeminiGenerationConfig? = nil
    ) {
        self.apiKey = apiKey
        self.model = model
        self.systemInstruction = systemInstruction
        self.generationConfig = generationConfig
    }

    public static func environment(
        model: String = "gemini-2.0-flash",
        systemInstruction: String? = nil,
        generationConfig: GeminiGenerationConfig? = nil
    ) throws -> GeminiConfiguration {
        guard let apiKey = Environment.get("GEMINI_API_KEY") else {
            throw GeminiClientError.missingAPIKey
        }
        return GeminiConfiguration(
            apiKey: apiKey,
            model: model,
            systemInstruction: systemInstruction,
            generationConfig: generationConfig
        )
    }
}
