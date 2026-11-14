import SwiftUI

/// Representa os 5 tons de lapidação suportados pelo Lapida
public enum RewriteTone: String, CaseIterable, Identifiable {
    case fix = "fix"
    case summarize = "summarize"
    case expand = "expand"
    case professional = "professional"
    case friendly = "friendly"
    
    public var id: String { rawValue }
    
    /// Nome de exibição na interface
    public var title: String {
        switch self {
        case .fix:          return "Corrigir e Lapidar"
        case .summarize:    return "Resumir"
        case .expand:       return "Complementar"
        case .professional: return "Mais Profissional"
        case .friendly:     return "Mais Amigável"
        }
    }
    
    /// Descrição curta para legendas e tooltips
    public var subtitle: String {
        switch self {
        case .fix:          return "Corrige ortografia e fluidez"
        case .summarize:    return "Sintetiza textos longos"
        case .expand:       return "Enriquece e expande argumentos"
        case .professional: return "Tom formal e corporativo"
        case .friendly:     return "Tom caloroso e próximo"
        }
    }
    
    /// Símbolo visual minimalista
    public var iconSymbol: String {
        switch self {
        case .fix:          return "sparkles"
        case .summarize:    return "doc.text"
        case .expand:       return "arrow.up.right"
        case .professional: return "briefcase.fill"
        case .friendly:     return "heart.fill"
        }
    }
    
    /// Caractere unicode alternativo para interfaces compactas
    public var unicodeIcon: String {
        switch self {
        case .fix:          return "✦"
        case .summarize:    return "📄"
        case .expand:       return "↗"
        case .professional: return "⬛"
        case .friendly:     return "♥"
        }
    }
    
    /// Cor primária temática oficial de cada opção
    public var colorHex: String {
        switch self {
        case .fix:          return "#007AFF" // Azul vibrante
        case .summarize:    return "#FF9500" // Laranja
        case .expand:       return "#34C759" // Verde
        case .professional: return "#636366" // Cinza escuro
        case .friendly:     return "#FF3B30" // Vermelho maçã
        }
    }
    
    public var color: Color {
        Color(hex: colorHex)
    }
    
    /// Prompt de engenharia refinado para a API Google Gemini
    public var systemInstruction: String {
        switch self {
        case .fix:
            return """
            Regras obrigatórias:
            1. Corrija todos os erros ortográficos, gramaticais e de concordância (ex: diferencie corretamente "mas" de "mais", "a gente" de "agente", "está" de "esta").
            2. Substitua abreviações informais de internet ("vc", "tb", "to", "ta", "pq", "q", "aq") pelas palavras completas ("você", "também", "estou", "está", "porque", "que", "aqui"), a menos que o contexto exija extrema informalidade.
            3. Aplique pontuação adequada (vírgulas, pontos finais, interrogações) para dar clareza e fluidez à leitura.
            4. Mantenha o tom de voz original (não transforme uma conversa casual com um amigo em um e-mail jurídico, apenas deixe-a bem escrita e educada).
            5. Retorne APENAS o texto final corrigido, sem aspas, sem introduções ("Aqui está:") e sem explicações.
            """
        case .summarize:
            return """
            Reescreva o texto de forma concisa e organizada, condensando TODOS os fatos e pontos principais mencionados pelo usuário sem omitir o meio da história.
            Regras:
            1. Não copie apenas o início e o fim: sintetize o começo, o desenvolvimento e a conclusão em 1 ou 2 frases bem conectadas.
            2. Remova repetições, vícios de linguagem ("mano", "aí", "kkkkk") e enrolações, mantendo apenas os acontecimentos-chave.
            3. Preserve o tom natural de conversa de chat e corrija ortografia e pontuação.
            4. Retorne apenas o texto final, sem aspas ou comentários.
            """
        case .expand:
            return """
            Expanda e enriqueça o texto original, aprofundando os argumentos e trazendo detalhes, exemplos e uma articulação mais convincente e acolhedora. Retorne APENAS o texto expandido, sem introduções ou aspas.
            """
        case .professional:
            return """
            Reescreva a mensagem com tom corporativo, refinado, cortês e direto ao ponto, adequado para comunicação profissional entre colegas, clientes ou parceiros de trabalho. Retorne APENAS o texto final, sem comentários.
            """
        case .friendly:
            return """
            Reescreva de forma amigável, acolhedora, empática e descontraída, como quem conversa com um amigo muito querido. Retorne APENAS o texto lapidado, sem introduções.
            """
        }
    }
}

// Extensão utilitária para SwiftUI Color a partir de Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
