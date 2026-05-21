import Vapor

/// Thread-safe in-memory store for AI context data, feedback, and recaps.
/// Uses Vapor's StorageKey pattern for Application-level access.
actor AIContextStore {
    private var contextData: ContextData?
    private var cachedFeedback: FeedbackResponse?
    private var cachedRecaps: [String: RecapResponse] = [:]

    // MARK: - Context

    func updateContext(_ data: ContextData) {
        self.contextData = data
    }

    func getContext() -> ContextData? {
        return contextData
    }

    // MARK: - Feedback

    func updateFeedback(_ feedback: FeedbackResponse) {
        self.cachedFeedback = feedback
    }

    func getFeedback() -> FeedbackResponse? {
        return cachedFeedback
    }

    // MARK: - Recap

    func updateRecap(type: RecapType, recap: RecapResponse) {
        self.cachedRecaps[type.rawValue] = recap
    }

    func getRecap(type: RecapType) -> RecapResponse? {
        return cachedRecaps[type.rawValue]
    }
}

// MARK: - Vapor Integration

/// StorageKey for registering AIContextStore on Application.
struct AIContextStoreKey: StorageKey {
    typealias Value = AIContextStore
}

extension Application {
    /// Access the shared AIContextStore instance.
    var contextStore: AIContextStore {
        get {
            guard let store = storage[AIContextStoreKey.self] else {
                fatalError("AIContextStore not configured. Call app.initializeContextStore() in configure.swift.")
            }
            return store
        }
        set {
            storage[AIContextStoreKey.self] = newValue
        }
    }

    /// Initialize the AIContextStore. Call this in configure.swift.
    func initializeContextStore() {
        self.contextStore = AIContextStore()
    }
}

extension Request {
    /// Access the AIContextStore from a request handler.
    var contextStore: AIContextStore {
        application.contextStore
    }
}
