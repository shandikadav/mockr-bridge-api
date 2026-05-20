import Vapor

public struct GeminiService: Sendable {
    public let client: GeminiClient

    public init(configuration: GeminiConfiguration) {
        self.client = GeminiClient(configuration: configuration)
    }
}

private struct GeminiServiceKey: StorageKey {
    typealias Value = GeminiService
}

extension Application {
    public var gemini: GeminiService {
        get {
            guard let service = storage[GeminiServiceKey.self] else {
                fatalError(
                    "GeminiService not configured. Call app.configureGemini(with:) in configure.swift"
                )
            }
            return service
        }
        set {
            storage[GeminiServiceKey.self] = newValue
        }
    }

    public func configureGemini(with configuration: GeminiConfiguration) {
        self.gemini = GeminiService(configuration: configuration)
    }

    public func configureGemini(
        apiKey: String? = nil,
        model: String = "gemini-2.0-flash",
        systemInstruction: String? = nil,
        generationConfig: GeminiGenerationConfig? = nil
    ) throws {
        if let key = apiKey {
            let config = GeminiConfiguration(
                apiKey: key,
                model: model,
                systemInstruction: systemInstruction,
                generationConfig: generationConfig
            )
            self.gemini = GeminiService(configuration: config)
        } else {
            let config = try GeminiConfiguration.environment(
                model: model,
                systemInstruction: systemInstruction,
                generationConfig: generationConfig
            )
            self.gemini = GeminiService(configuration: config)
        }
    }
}

extension Request {
    public var gemini: GeminiClient {
        application.gemini.client
    }
}
