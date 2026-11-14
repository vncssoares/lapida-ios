import Foundation

/// Motor de reescrita local inteligente em Swift para o Lapida iOS
/// Funciona offline ou como fallback de alta precisão quando a API não estiver disponível.
public final class LocalRewriteEngine {
    public static let shared = LocalRewriteEngine()
    
    private init() {}
    
    public func rewrite(_ text: String, tone: RewriteTone) -> String {
        var t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty { return "" }
        
        // ETAPA 1: Expansão de abreviações informais
        let abreviacoes: [(pattern: String, replacement: String)] = [
            ("\\bvc\\b", "você"),
            ("\\bvcs\\b", "vocês"),
            ("\\btb\\b", "também"),
            ("\\btmb\\b", "também"),
            ("\\bpq\\b", "porque"),
            ("\\bpor q\\b", "por que"),
            ("\\bq\\b(?=[\\s,!?.]|$)", "que"),
            ("\\bto\\b(?=\\s)", "estou"),
            ("\\btô\\b", "estou"),
            ("(?<!\\w)ta\\b(?=\\s)", "está"),
            ("\\btá\\b", "está"),
            ("\\btava\\b", "estava"),
            ("\\btavamos\\b", "estávamos"),
            ("\\bnum\\b(?!\\s*(?:lugar|momento|instante|dia|mês|ano|canto))", "não"),
            ("\\bnuma\\b", "em uma"),
            ("\\bblz\\b", "beleza"),
            ("\\bmto\\b", "muito"),
            ("\\bmt\\b", "muito"),
            ("\\bmsm\\b", "mesmo"),
            ("\\bqnd\\b", "quando"),
            ("\\bkk+\\b", ""),
            ("\\brs+\\b", ""),
            ("\\bhahaha*\\b", ""),
            ("\\bne[h]?\\b", "né"),
            ("\\bpfv\\b", "por favor"),
            ("\\bobg\\b", "obrigado"),
            ("\\bvlw\\b", "valeu"),
            ("\\bflw\\b", "falou"),
            ("\\bsdds\\b", "saudades"),
            ("\\bsds\\b", "saudades"),
            ("\\btd\\b", "tudo"),
            ("\\btds\\b", "todos"),
            ("\\bml\\b", "mal"),
            ("\\bpdc\\b", "pode crer"),
            ("\\bss\\b", "sim"),
            ("\\bcmg\\b", "comigo"),
            ("\\bctg\\b", "contigo"),
            ("\\bdms\\b", "demais"),
            ("\\bqm\\b", "quem"),
            ("\\bnd\\b", "nada"),
            ("\\bngm\\b", "ninguém"),
            ("\\bpra\\b", "para"),
            ("\\bpro\\b(?=\\s)", "para o"),
            ("\\bdpois\\b", "depois"),
            ("\\bagr\\b", "agora"),
            ("\\bhj\\b", "hoje"),
            ("\\bamh\\b", "amanhã"),
            ("\\bmsg\\b", "mensagem"),
            ("\\bmsgs\\b", "mensagens"),
            ("\\bfds\\b", "fim de semana"),
            ("\\bdboa\\b", "de boa"),
            ("\\boq\\b", "o que"),
            ("\\baq\\b", "aqui"),
            ("\\baki\\b", "aqui"),
            ("\\bola\\b", "olá"),
            ("\\bol\\b", "olá")
        ]
        
        for (pattern, replacement) in abreviacoes {
            t = replacingRegex(in: t, pattern: pattern, with: replacement, options: .caseInsensitive)
        }
        
        // ETAPA 2: Correções ortográficas e acentuações frequentes
        let ortografia: [(pattern: String, replacement: String)] = [
            ("\\binteligencia\\b", "inteligência"),
            ("\\bproximos\\b", "próximos"),
            ("\\bproximo\\b", "próximo"),
            ("\\bproxima\\b", "próxima"),
            ("\\bproximas\\b", "próximas"),
            ("\\bcodigo\\b", "código"),
            ("\\bcodigos\\b", "códigos"),
            ("\\btras\\b(?=\\s|$|[.,!?])", "trás"),
            ("\\batras\\b", "atrás"),
            ("\\bduvida\\b", "dúvida"),
            ("\\bduvidas\\b", "dúvidas"),
            ("\\bnumero\\b", "número"),
            ("\\bnumeros\\b", "números"),
            ("\\bpossivel\\b", "possível"),
            ("\\bfaceis\\b", "fáceis"),
            ("\\bfacil\\b", "fácil"),
            ("\\bdificil\\b", "difícil"),
            ("\\bhorario\\b", "horário"),
            ("\\bhorarios\\b", "horários"),
            ("\\bja\\b(?=\\s)", "já"),
            ("\\bate\\b(?=\\s)", "até"),
            ("\\bnao\\b", "não"),
            ("\\bvoce\\b", "você"),
            ("\\bvoces\\b", "vocês"),
            ("\\btambem\\b", "também"),
            ("\\bso\\b(?=\\s)", "só")
        ]
        
        for (pattern, replacement) in ortografia {
            t = replacingRegex(in: t, pattern: pattern, with: replacement, options: .caseInsensitive)
        }
        
        // ETAPA 3: Diferenciação entre "mais" e "mas"
        t = replacingRegex(in: t,
                           pattern: "\\bmais\\s+(eu|não|nao|ele|ela|a gente|nós|eles|elas|isso|aí|aqui|acho|preciso|quero|vou|tenho|sei|estou|está|tudo|ainda|depois|mesmo|quando|se|agora|foi|era|já|só|daí|enfim|tipo|como)\\b",
                           with: "mas $1",
                           options: .caseInsensitive)
        
        t = replacingRegex(in: t,
                           pattern: "(ado|ada|ido|ida|oso|osa|nte|ste|mos|ram|ou|ei|iu)\\s+mais\\s+",
                           with: "$1 mas ",
                           options: .caseInsensitive)
        
        t = replacingRegex(in: t, pattern: ",\\s*mais\\s+", with: ", mas ", options: .caseInsensitive)
        
        // ETAPA 4: Concordância e gramática
        t = replacingRegex(in: t, pattern: "\\bos cara\\b", with: "os caras", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "\\bas mina\\b", with: "as minas", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "\\bos menino\\b", with: "os meninos", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "\\bas menina\\b", with: "as meninas", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "\\beles faz\\b", with: "eles fazem", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "\\beles vai\\b", with: "eles vão", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "\\bnós vai\\b", with: "nós vamos", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "\\ba gente vamos\\b", with: "a gente vai", options: .caseInsensitive)
        
        // ETAPA 5: Limpeza de espaços duplos
        t = replacingRegex(in: t, pattern: "\\s{2,}", with: " ")
        t = replacingRegex(in: t, pattern: "\\s+([.,!?;:])", with: "$1")
        
        // ETAPA 6: Pontuação inteligente
        t = replacingRegex(in: t, pattern: "([a-záàâãéèêíïóôõöúüç])\\s+(mas|porém|contudo|entretanto|todavia)\\s", with: "$1, $2 ", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: ",\\s*,", with: ",")
        t = replacingRegex(in: t, pattern: "([a-záàâãéèêíïóôõöúüç])\\s+(porque)\\s", with: "$1, $2 ", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "^(amor|mano|cara|gente|pessoal|oi|ei|olha|amiga|amigo)\\s+", with: "$1, ", options: .caseInsensitive)
        t = replacingRegex(in: t, pattern: "([a-záàâãéèêíïóôõöúüç])\\s+(só que|só)\\s", with: "$1, $2 ", options: .caseInsensitive)
        
        // ETAPA 7: Capitalização da primeira letra e pontuação terminal
        t = t.trimmingCharacters(in: .whitespacesAndNewlines)
        if let first = t.first {
            t = String(first).uppercased() + String(t.dropFirst())
        }
        
        if let last = t.last, !".!?".contains(last) {
            t.append(".")
        }
        
        // APLICAÇÃO POR TOM ESPECÍFICO
        switch tone {
        case .fix:
            return t
            
        case .summarize:
            return summarizeText(t)
            
        case .expand:
            return expandText(t)
            
        case .professional:
            return professionalizeText(t)
            
        case .friendly:
            let emojis = ["😊", "🤗", "😄", "✨", "💙", "🙌", "😁", "❤️"]
            let randomEmoji = emojis.randomElement() ?? "😊"
            if t.hasSuffix(".") {
                t.removeLast()
            }
            return "\(t) \(randomEmoji)"
        }
    }
    
    // MARK: - Modos Especializados
    
    private func summarizeText(_ text: String) -> String {
        var s = text
        let removePatterns = [
            "\\b(kkk+|rsrs+|hahaha+|hehehe+)\\b",
            "\\b(mano|cara|vei|véi|velho|irmão|parceiro),?\\s*",
            "\\b(tipo assim|tipo|sabe|né|aí|daí|então),?\\s*",
            "\\b(olha|veja bem|bom|na verdade|pra falar a verdade),?\\s*",
            "\\b(eu acho que|eu acredito que|na minha opinião),?\\s*",
            "\\b(como eu falei|como eu disse|como você sabe),?\\s*"
        ]
        
        for pattern in removePatterns {
            s = replacingRegex(in: s, pattern: pattern, with: "", options: .caseInsensitive)
        }
        
        s = replacingRegex(in: s, pattern: "\\s{2,}", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        
        var clauses = s.components(separatedBy: CharacterSet(charactersIn: ".!?;")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.count > 5 }
        
        if clauses.count <= 1 {
            clauses = s.components(separatedBy: " mas ").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.count > 5 }
        }
        
        if clauses.count >= 3 {
            let inicio = clauses[0]
            let meio = clauses[clauses.count / 2]
            let fim = clauses[clauses.count - 1]
            s = "\(inicio), \(meio.prefix(1).lowercased())\(meio.dropFirst()), e \(fim.prefix(1).lowercased())\(fim.dropFirst())"
        } else if clauses.count == 2 {
            let p1 = clauses[0]
            let p2 = clauses[1]
            s = "\(p1), \(p2.prefix(1).lowercased())\(p2.dropFirst())"
        }
        
        s = replacingRegex(in: s, pattern: ",\\s*,", with: ",")
        s = replacingRegex(in: s, pattern: "\\s{2,}", with: " ")
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: " ,.-"))
        
        if let first = s.first {
            s = String(first).uppercased() + String(s.dropFirst())
        }
        if let last = s.last, !".!?".contains(last) {
            s.append(".")
        }
        return s
    }
    
    private func expandText(_ text: String) -> String {
        let lower = text.lowercased()
        let addon: String
        if lower.contains("trabalho") || lower.contains("projeto") || lower.contains("reunião") {
            addon = " Essa questão é prioritária para o andamento dos projetos e merece alinhamento estratégico."
        } else if lower.contains("sentimento") || lower.contains("chateado") || lower.contains("bravo") || lower.contains("feliz") {
            addon = " É fundamental reconhecer essas percepções com empatia e diálogo aberto para avançarmos bem."
        } else if lower.contains("decisão") || lower.contains("pensar") || lower.contains("escolha") {
            addon = " Analisando com calma os prós e contras, chegaremos à alternativa mais equilibrada e assertiva."
        } else {
            addon = " Acredito que com uma comunicação clara e assertiva conseguiremos alcançar o melhor resultado."
        }
        return text + addon
    }
    
    private func professionalizeText(_ text: String) -> String {
        var s = text
        let terms: [(String, String)] = [
            ("\\beu quero\\b", "solicito"),
            ("\\bquero\\b", "gostaria de"),
            ("\\bpreciso\\b", "necessito"),
            ("\\bfazer\\b", "realizar"),
            ("\\bcoisa\\b", "questão"),
            ("\\bmuito bom\\b", "excelente"),
            ("\\bobrigado\\b", "agradeço"),
            ("\\bdesculpa\\b", "peço desculpas"),
            ("\\bné\\b", "não é mesmo"),
            ("\\bna verdade\\b", "na realidade"),
            ("\\bchateado\\b", "insatisfeito"),
            ("\\bbravo\\b", "descontente")
        ]
        
        for (pat, rep) in terms {
            s = replacingRegex(in: s, pattern: pat, with: rep, options: .caseInsensitive)
        }
        
        let lower = s.lowercased()
        let prefixes = ["solicito", "gostaria", "prezado", "caro", "conforme", "informo", "venho por meio"]
        if !prefixes.contains(where: { lower.hasPrefix($0) }) {
            if let first = s.first {
                s = "Informo que " + String(first).lowercased() + String(s.dropFirst())
            }
        }
        return s
    }
    
    // MARK: - Auxiliares Regex
    
    private func replacingRegex(in string: String, pattern: String, with template: String, options: NSRegularExpression.Options = []) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return string
        }
        let range = NSRange(string.startIndex..., in: string)
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: template)
    }
}
