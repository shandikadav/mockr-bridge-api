import Vapor

struct ChatRequest: Content {
    let message: String
    let systemInstruction: String?
    let context: String?

    init(message: String, systemInstruction: String? = nil, context: String? = nil) {
        self.message = message
        self.systemInstruction = systemInstruction
        self.context = context
    }
}

struct ChatResponse: Content {
    let reply: String
}
