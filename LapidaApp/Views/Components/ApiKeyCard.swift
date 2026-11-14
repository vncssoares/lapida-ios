import SwiftUI

/// Card de configuração da API Key do Gemini com armazenamento seguro em App Groups
public struct ApiKeyCard: View {
    @Binding var apiKeyInput: String
    @Binding var isSaved: Bool
    @State private var isVisible: Bool = false
    @State private var showSavedAlert: Bool = false
    
    public init(apiKeyInput: Binding<String>, isSaved: Binding<Bool>) {
        self._apiKeyInput = apiKeyInput
        self._isSaved = isSaved
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "#007AFF").opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "key.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "#007AFF"))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Configuração da IA (Gemini)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Armazenada em App Groups compartilhado")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
                
                Spacer()
                
                // Badge de status
                HStack(spacing: 5) {
                    Circle()
                        .fill(isSaved ? Color(hex: "#34C759") : Color(hex: "#FF9500"))
                        .frame(width: 7, height: 7)
                    
                    Text(isSaved ? "Ativa" : "Pendente")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(isSaved ? Color(hex: "#34C759") : Color(hex: "#FF9500"))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill((isSaved ? Color(hex: "#34C759") : Color(hex: "#FF9500")).opacity(0.12))
                )
            }
            
            Text("Cole sua API Key do Google AI Studio. A chave fica disponível automaticamente para a extensão de teclado Lapida.")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#A1A1A6"))
                .lineSpacing(2)
            
            // Campo de texto protegido com botão de visualização
            HStack(spacing: 10) {
                Group {
                    if isVisible {
                        TextField("Cole sua chave AIzaSy...", text: $apiKeyInput)
                    } else {
                        SecureField("Cole sua chave AIzaSy...", text: $apiKeyInput)
                    }
                }
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            
            // Botão Salvar
            Button(action: saveKey) {
                HStack(spacing: 8) {
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "arrow.down.doc.fill")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(isSaved ? "Atualizar Chave do Teclado" : "Salvar Chave no Teclado")
                        .font(.system(size: 14, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#007AFF"), Color(hex: "#0055D4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(hex: "#1C1C1E"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: "#2C2C2E"), lineWidth: 1)
        )
    }
    
    private func saveKey() {
        let clean = apiKeyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        SharedStorage.shared.geminiApiKey = clean
        isSaved = !clean.isEmpty
        
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
