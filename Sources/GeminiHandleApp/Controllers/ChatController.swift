import Vapor
import GeminiHandle

struct ChatController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let chat = routes.grouped("api", "chat")
        chat.post(use: sendMessage)
        chat.post("stream", use: streamMessage)
    }

    @Sendable
    func sendMessage(req: Request) async throws -> ChatResponse {
        let chatRequest = try req.content.decode(ChatRequest.self)

        let reply = try await req.gemini.generate(
            prompt: chatRequest.message,
            using: req.client,
            systemInstruction: chatRequest.systemInstruction
        )

        return ChatResponse(reply: reply)
    }

    @Sendable
    func streamMessage(req: Request) async throws -> Response {
        let chatRequest = try req.content.decode(ChatRequest.self)

        let stream = req.gemini.streamResponse(
            prompt: chatRequest.message,
            using: req.client,
            systemInstruction: chatRequest.systemInstruction
        )

        let response = Response(
            status: .ok,
            headers: HTTPHeaders([
                ("Content-Type", "text/event-stream"),
                ("Cache-Control", "no-cache"),
                ("Connection", "keep-alive"),
            ])
        )

        response.body = .init(stream: { writer in
            Task {
                do {
                    for try await chunk in stream {
                        let data = try JSONEncoder().encode(chunk)
                        _ = writer.write(.buffer(ByteBuffer(data: data)))
                    }
                    _ = writer.write(.end)
                } catch {
                    _ = writer.write(.error(error))
                }
            }
        })

        return response
    }
}
