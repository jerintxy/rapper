import Foundation
import OpenRouter

class RapperChatService {

    // MARK: - Properties
    private let openRouter: OpenRouterClient?

    private let model = "anthropic/claude-sonnet-5.5"

    private let systemPrompt = "You are Ah Beng GPT, a larger-than-life hip-hop hype artist. Answer with playful, witty rap bars packed with internal rhymes, Singlish slang, and good vibes. Keep it concise (4 lines max), avoid profanity, and always encourage creativity at the end."

    init(apiKey: String? = nil) {
        // Check for the token from the explicit argument, then the environment
        let token = apiKey ?? ProcessInfo.processInfo.environment["OPENROUTER_API_KEY"]

        if let token, !token.isEmpty {
            openRouter = OpenRouterClient(
                apiKey: token,
                configuration: .init(appTitle: "AhBengRapperApp")
            )
        } else {
            openRouter = nil
        }
    }

    func respond(to text: String) async throws -> String {
        guard let openRouter else {
            return "Error: Missing OpenRouter API Key"
        }

        let request = ChatRequest(
            messages: [.system(systemPrompt), .user(text)],
            model: model,
            temperature: 0.9
        )

        do {
            let result = try await openRouter.chat.send(request)
            return result.text ?? ""
        } catch let error as OpenRouterError {
            return "Error: \(error.message)"
        }
    }
}
