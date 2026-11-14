import Foundation

/// Gerenciador de armazenamento compartilhado entre o aplicativo principal e a extensão de teclado (App Groups)
public final class SharedStorage {
    public static let shared = SharedStorage()
    
    /// Identificador do App Group oficial configurado no portal Apple Developer / Entitlements
    public static let appGroupIdentifier = "group.com.lapida.app"
    
    private let appGroupDefaults: UserDefaults?
    private let standardDefaults: UserDefaults = .standard
    
    private enum Keys {
        static let geminiApiKey = "lapida_gemini_api_key"
        static let isHapticEnabled = "lapida_haptic_feedback_enabled"
        static let preferredModel = "lapida_preferred_gemini_model"
        static let hasConfiguredOnce = "lapida_has_configured_once"
        static let lastRewrittenText = "lapida_last_rewritten_text"
    }
    
    private init() {
        self.appGroupDefaults = UserDefaults(suiteName: SharedStorage.appGroupIdentifier)
    }
    
    /// UserDefaults ativo: prioriza o App Group compartilhado; fallback para o standard
    private var activeDefaults: UserDefaults {
        appGroupDefaults ?? standardDefaults
    }
    
    // MARK: - Chave de API Google Gemini
    
    public var geminiApiKey: String {
        get {
            // Tenta ler do App Group; se vazio, tenta do standard
            if let key = appGroupDefaults?.string(forKey: Keys.geminiApiKey), !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return key.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return standardDefaults.string(forKey: Keys.geminiApiKey)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
        set {
            let sanitized = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            appGroupDefaults?.set(sanitized, forKey: Keys.geminiApiKey)
            standardDefaults.set(sanitized, forKey: Keys.geminiApiKey)
            appGroupDefaults?.synchronize()
            standardDefaults.synchronize()
        }
    }
    
    public var hasValidApiKey: BooleanLiteralType {
        let key = geminiApiKey
        return !key.isEmpty && key.count >= 15
    }
    
    // MARK: - Preferências do Teclado
    
    public var isHapticEnabled: Bool {
        get {
            if activeDefaults.object(forKey: Keys.isHapticEnabled) == nil {
                return true // Ativado por padrão
            }
            return activeDefaults.bool(forKey: Keys.isHapticEnabled)
        }
        set {
            activeDefaults.set(newValue, forKey: Keys.isHapticEnabled)
        }
    }
    
    public var preferredModel: String {
        get {
            activeDefaults.string(forKey: Keys.preferredModel) ?? "gemini-2.5-flash"
        }
        set {
            activeDefaults.set(newValue, forKey: Keys.preferredModel)
        }
    }
    
    public var hasConfiguredOnce: Bool {
        get {
            activeDefaults.bool(forKey: Keys.hasConfiguredOnce)
        }
        set {
            activeDefaults.set(newValue, forKey: Keys.hasConfiguredOnce)
        }
    }
    
    public var lastRewrittenText: String {
        get {
            activeDefaults.string(forKey: Keys.lastRewrittenText) ?? ""
        }
        set {
            activeDefaults.set(newValue, forKey: Keys.lastRewrittenText)
        }
    }
    
    /// Limpa todos os dados salvos (logout / reset)
    public func clearAll() {
        appGroupDefaults?.removeObject(forKey: Keys.geminiApiKey)
        appGroupDefaults?.removeObject(forKey: Keys.isHapticEnabled)
        appGroupDefaults?.removeObject(forKey: Keys.preferredModel)
        standardDefaults.removeObject(forKey: Keys.geminiApiKey)
        standardDefaults.removeObject(forKey: Keys.isHapticEnabled)
        standardDefaults.removeObject(forKey: Keys.preferredModel)
    }
}
