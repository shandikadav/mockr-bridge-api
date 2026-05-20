import Vapor

public struct GeminiStreamResponse: Content, Sendable {
    public let text: String
    public let done: Bool

    public init(text: String, done: Bool = false) {
        self.text = text
        self.done = done
    }
}

extension GeminiClient {
    public func streamResponse(
        prompt: String,
        using client: any Client,
        systemInstruction: String? = nil
    ) -> AsyncThrowingStream<GeminiStreamResponse, any Error> {
        let config = configuration
        let systemContent = systemInstruction ?? config.systemInstruction

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let url = "\(config.baseURL)/\(config.model):streamGenerateContent?alt=sse&key=\(config.apiKey)"

                    let response = try await client.post(URI(string: url)) { req in
                        req.headers.contentType = .json
                        let body = GeminiGenerateRequest(
                            contents: [GeminiContent.user(prompt)],
                            systemInstruction: systemContent.map { GeminiContent(role: nil, parts: [GeminiPart(text: $0)]) },
                            generationConfig: config.generationConfig
                        )
                        try req.content.encode(body)
                    }

                    guard let data = response.body else {
                        throw GeminiClientError.emptyResponse
                    }

                    let rawText = String(buffer: data)

                    for line in rawText.components(separatedBy: "\n") {
                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard trimmed.hasPrefix("data: ") else { continue }

                        let jsonStr = String(trimmed.dropFirst(6))

                        if jsonStr.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]" {
                            continuation.yield(GeminiStreamResponse(text: "", done: true))
                            continuation.finish()
                            return
                        }

                        guard let chunkData = jsonStr.data(using: .utf8),
                              let streamRes = try? JSONDecoder().decode(
                                GeminiGenerateResponse.self, from: chunkData),
                              let text = streamRes.candidates?.first?.content?.parts.first?.text
                        else { continue }

                        let isDone = streamRes.candidates?.first?.finishReason != nil
                        continuation.yield(GeminiStreamResponse(text: text, done: isDone))
                    }

                    continuation.yield(GeminiStreamResponse(text: "", done: true))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
