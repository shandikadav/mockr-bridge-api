import Vapor

public final class GeminiClient: Sendable {
    let configuration: GeminiConfiguration

    public init(configuration: GeminiConfiguration) {
        self.configuration = configuration
    }

    public var model: String { configuration.model }
    public var apiKey: String { configuration.apiKey }

    // MARK: - Simple Prompt

    public func generate(
        prompt: String,
        using client: any Client,
        systemInstruction: String? = nil
    ) async throws -> String {
        let systemContent = systemInstruction ?? configuration.systemInstruction
        let contents = [GeminiContent.user(prompt)]
        return try await generateContent(
            contents: contents,
            using: client,
            systemInstruction: systemContent
        )
    }

    // MARK: - Chat with History

    public func chat(
        messages: [GeminiChatMessage],
        using client: any Client,
        systemInstruction: String? = nil
    ) async throws -> String {
        let systemContent = systemInstruction ?? configuration.systemInstruction
        let geminiContents = messages.map { msg -> GeminiContent in
            GeminiContent(role: msg.role, parts: [GeminiPart(text: msg.text)])
        }
        return try await generateContent(
            contents: geminiContents,
            using: client,
            systemInstruction: systemContent
        )
    }

    // MARK: - Count Tokens

    public func countTokens(
        text: String,
        using client: any Client
    ) async throws -> Int {
        let url = "\(configuration.baseURL)/\(configuration.model):countTokens?key=\(configuration.apiKey)"
        let body = GeminiCountTokensRequest(contents: [GeminiContent.user(text)])

        let response = try await client.post(URI(string: url)) { req in
            req.headers.contentType = .json
            try req.content.encode(body)
        }

        guard let data = response.body else {
            throw GeminiClientError.emptyResponse
        }

        if let apiError = try? JSONDecoder().decode(GeminiAPIError.self, from: data) {
            throw apiError
        }

        let tokenResponse = try JSONDecoder().decode(GeminiCountTokensResponse.self, from: data)
        return tokenResponse.totalTokens ?? 0
    }

    // MARK: - Private

    private func generateContent(
        contents: [GeminiContent],
        using client: any Client,
        systemInstruction: String?
    ) async throws -> String {
        let url = "\(configuration.baseURL)/\(configuration.model):generateContent?key=\(configuration.apiKey)"

        let requestBody = GeminiGenerateRequest(
            contents: contents,
            systemInstruction: systemInstruction.map { GeminiContent(role: nil, parts: [GeminiPart(text: $0)]) },
            generationConfig: configuration.generationConfig
        )

        let response = try await client.post(URI(string: url)) { req in
            req.headers.contentType = .json
            try req.content.encode(requestBody)
        }

        return try parseResponse(response)
    }

    private func parseResponse(_ response: ClientResponse) throws -> String {
        guard let body = response.body else {
            throw GeminiClientError.emptyResponse
        }

        if let apiError = try? JSONDecoder().decode(GeminiAPIError.self, from: body) {
            throw apiError
        }

        let geminiResponse = try JSONDecoder().decode(GeminiGenerateResponse.self, from: body)

        if let feedback = geminiResponse.promptFeedback, feedback.blockReason != nil {
            throw GeminiClientError.blocked(reason: feedback.blockReason)
        }

        guard let candidate = geminiResponse.candidates?.first,
              let text = candidate.content?.parts.first?.text else {
            throw GeminiClientError.noCandidates
        }

        return text
    }
}

extension GeminiConfiguration {
    var baseURL: String {
        "https://generativelanguage.googleapis.com/v1beta/models"
    }
}

// MARK: - Vapor Content conformance for models

extension GeminiGenerateRequest: Content {}
extension GeminiCountTokensRequest: Content {}
extension GeminiContent: Content {}
extension GeminiPart: Content {}
extension GeminiGenerationConfig: Content {}
