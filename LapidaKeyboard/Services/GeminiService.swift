import Foundation

public struct RewriteResult {
    public let text: String
    public let usedAI: Bool
    public let modelUsed: String?
    public let errorMessage: String?
    
    public init(text: String, usedAI: Bool, modelUsed: String? = nil, errorMessage: String? = nil) {
        self.text = text
        self.usedAI = usedAI
        self.modelUsed = modelUsed
        self.errorMessage = errorMessage
    }
}

public final class GeminiService {
    public static let shared = GeminiService()
    
    private let session: URLSession
    private let candidateModels = ["gemini-2.5-flash", "gemini-2.0-flash", "gemini-1.5-flash"]
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 18
        config.timeoutIntervalForResource = 25
        self.session = URLSession(configuration: config)
    }
    
    /// Lapida o texto usando o modelo Gemini especificado, com fallback inteligente para o motor local
    public func rewrite(text: String, tone: RewriteTone) async -> RewriteResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return RewriteResult(text: "", usedAI: false, errorMessage: "Texto vazio")
        }
        
        let apiKey = SharedStorage.shared.geminiApiKey
        
        // Se a chave não estiver configurada, aplica diretamente o motor local com excelência
        if apiKey.isEmpty {
            let localResult = LocalRewriteEngine.shared.rewrite(trimmed, tone: tone)
            return RewriteResult(text: localResult, usedAI: false, errorMessage: "API Key não configurada. Usando motor local.")
        }
        
        let systemInstruction = """
        Você é o Lapida, um motor de IA especializado em lapidação e reescrita de mensagens para iPhone e mensageiros (WhatsApp, Telegram, E-mail).
        Sua missão é lapidar o texto do usuário de acordo com o tom solicitado.
        
        DIRETRIZES ESTRITAS:
        1. Retorne APENAS o texto lapidado final.
        2. NUNCA inclua introduções, saudações ou explicações (ex: NUNCA diga 'Aqui está:' ou 'Versão corrigida:').
        3. NUNCA envolva o texto com aspas adicionais.
        4. Preserve o idioma original do texto.
        5. Mantenha emojis existentes ou adicione-os de forma natural apenas se condizente com o tom amigável.
        """
        
        let promptPayload: [String: Any] = [
            "systemInstruction": [
                "parts": [
                    ["text": systemInstruction]
                ]
            ],
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        [
                            "text": """
                            [Instrução de Tom]:
                            \(tone.systemInstruction)
                            
                            [Texto Original]:
                            \(trimmed)
                            """
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.4,
                "maxOutputTokens": 2048
            ]
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: promptPayload) else {
            let local = LocalRewriteEngine.shared.rewrite(trimmed, tone: tone)
            return RewriteResult(text: local, usedAI: false, errorMessage: "Falha na serialização do payload")
        }
        
        var lastError: String = ""
        
        // Tenta os modelos em cascata (2.5-flash -> 2.0-flash -> 1.5-flash)
        for model in candidateModels {
            let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
            guard let url = URL(string: urlString) else { continue }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            do {
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else { continue }
                
                if httpResponse.statusCode == 200 {
                    if let parsed = parseGeminiResponse(data: data) {
                        let cleaned = cleanEnclosingQuotes(parsed)
                        return RewriteResult(text: cleaned, usedAI: true, modelUsed: model)
                    }
                } else {
                    let errObj = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                    let errorDict = errObj?["error"] as? [String: Any]
                    let msg = errorDict?["message"] as? String ?? "HTTP \(httpResponse.statusCode)"
                    lastError = "API [\(httpResponse.statusCode)]: \(msg)"
                    
                    // Se não for erro 404 de modelo ausente (ex: 400 chave inválida, 429 quota esgotada), não tenta os outros modelos
                    if httpResponse.statusCode != 404 {
                        break
                    }
                }
            } catch {
                lastError = "Erro de conexão: \(error.localizedDescription)"
            }
        }
        
        // Fallback automático para o motor local
        let fallbackText = LocalRewriteEngine.shared.rewrite(trimmed, tone: tone)
        return RewriteResult(text: fallbackText, usedAI: false, errorMessage: lastError)
    }
    
    private func parseGeminiResponse(data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            return nil
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func cleanEnclosingQuotes(_ text: String) -> String {
        var res = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if res.hasPrefix("\"") && res.hasSuffix("\"") && res.count >= 2 {
            res.removeFirst()
            res.removeLast()
        } else if res.hasPrefix("“") && res.hasSuffix("”") && res.count >= 2 {
            res.removeFirst()
            res.removeLast()
        }
        return res.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
