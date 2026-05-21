import Vapor
import GeminiHandle

/// Handles POST /api/v1/get-context
/// Receives context data from the client, processes it with Gemini AI,
/// and caches feedback + recaps for later retrieval.
struct ContextController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("get-context", use: processContext)
    }

    @Sendable
    func processContext(req: Request) async throws -> APIResponse<ContextResponse> {
        let contextRequest = try req.content.decode(ContextRequest.self)

        guard !contextRequest.entries.isEmpty else {
            throw Abort(.badRequest, reason: "Context entries cannot be empty.")
        }

        // Store the raw context
        let now = ISO8601DateFormatter().string(from: Date())
        let contextData = ContextData(
            entries: contextRequest.entries,
            updatedAt: now
        )
        await req.contextStore.updateContext(contextData)

        // Build a formatted context string for AI prompts
        let contextText = formatContextForAI(contextRequest.entries)

        // Generate feedback, daily recap, and weekly recap concurrently
        async let feedbackText = generateFeedback(
            context: contextText, req: req
        )
        async let dailyRecapText = generateRecap(
            type: .daily, context: contextText, req: req
        )
        async let weeklyRecapText = generateRecap(
            type: .weekly, context: contextText, req: req
        )

        let (feedback, dailyRecap, weeklyRecap) = try await (
            feedbackText, dailyRecapText, weeklyRecapText
        )

        // Cache results
        let feedbackResponse = FeedbackResponse(
            feedback: feedback, generatedAt: now
        )
        let dailyRecapResponse = RecapResponse(
            type: RecapType.daily.rawValue, recap: dailyRecap, generatedAt: now
        )
        let weeklyRecapResponse = RecapResponse(
            type: RecapType.weekly.rawValue, recap: weeklyRecap, generatedAt: now
        )

        await req.contextStore.updateFeedback(feedbackResponse)
        await req.contextStore.updateRecap(type: .daily, recap: dailyRecapResponse)
        await req.contextStore.updateRecap(type: .weekly, recap: weeklyRecapResponse)

        let response = ContextResponse(
            feedback: feedback,
            dailyRecap: dailyRecap,
            weeklyRecap: weeklyRecap,
            updatedAt: now
        )

        return .success(response, message: "Context processed and AI data generated successfully.")
    }

    // MARK: - Private Helpers

    /// Format context entries into a readable string for AI prompts.
    private func formatContextForAI(_ entries: [ContextEntry]) -> String {
        var lines: [String] = []
        let grouped = Dictionary(grouping: entries, by: { $0.category })

        for (category, items) in grouped.sorted(by: { $0.key < $1.key }) {
            lines.append("[\(category.uppercased())]")
            for item in items {
                let datePart = item.date.map { " (\($0))" } ?? ""
                lines.append("- \(item.title): \(item.value)\(datePart)")
            }
            lines.append("")
        }

        return lines.joined(separator: "\n")
    }

    /// Generate feedback using Gemini AI based on the provided context.
    private func generateFeedback(context: String, req: Request) async throws -> String {
        let prompt = """
        Based on the following user activity data, provide constructive and encouraging feedback. \
        Focus on patterns, achievements, and areas for improvement. Keep it concise and actionable.

        User Data:
        \(context)

        Provide your feedback in a clear, supportive tone.
        """

        return try await req.gemini.generate(
            prompt: prompt,
            using: req.client
        )
    }

    /// Generate a recap using Gemini AI based on the provided context and recap type.
    private func generateRecap(
        type: RecapType, context: String, req: Request
    ) async throws -> String {
        let timeframe = type == .daily ? "today's" : "this week's"
        let prompt = """
        Based on the following user activity data, create a \(type.rawValue) recap summarizing \
        \(timeframe) activities and progress. Highlight key accomplishments and notable patterns.

        User Data:
        \(context)

        Provide a structured \(type.rawValue) summary.
        """

        return try await req.gemini.generate(
            prompt: prompt,
            using: req.client
        )
    }
}
