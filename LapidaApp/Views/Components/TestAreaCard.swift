import SwiftUI

/// Área de teste interativa dentro do aplicativo para verificar o funcionamento da digitação e da IA
public struct TestAreaCard: View {
    @State private var sampleText: String = "ola tudo bem gostaria de saber se vc vai na reuniao amh pq preciso confirmar as coisa com a gente"
    @State private var selectedTone: RewriteTone = .fix
    @State private var isProcessing: Bool = false
    @State private var resultMessage: String?
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "#FF9500").opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "#FF9500"))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Área de Teste Rápido")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Toque abaixo para abrir o teclado ou lapidar")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
            }
            
            Text("Experimente digitar no campo abaixo com o teclado Lapida ativado, ou teste o motor de IA diretamente aqui:")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#A1A1A6"))
            
            // Campo de Texto Interativo (Chama o Teclado do iOS ao focar)
            TextEditor(text: $sampleText)
                .frame(minHeight: 85)
                .padding(10)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            // Botões de Ação Rápida dos 5 Tons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RewriteTone.allCases) { tone in
                        Button(action: { runQuickTest(tone: tone) }) {
                            HStack(spacing: 5) {
                                Text(tone.unicodeIcon)
                                    .font(.system(size: 11))
                                Text(tone.title)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(tone.color.opacity(selectedTone == tone ? 1.0 : 0.2))
                            )
                        }
                        .disabled(isProcessing)
                    }
                }
            }
            
            if isProcessing {
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#007AFF")))
                        .scaleEffect(0.8)
                    Text("Lapidando com \(selectedTone.title)...")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
                .padding(.top, 4)
            }
            
            if let result = resultMessage {
                Text(result)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#34C759"))
                    .padding(.top, 2)
            }
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
    
    private func runQuickTest(tone: RewriteTone) {
        selectedTone = tone
        isProcessing = true
        resultMessage = nil
        
        Task {
            // Se houver chave, chama a API Gemini; caso contrário, executa a reescrita local
            let result = await GeminiService.shared.rewrite(text: sampleText, tone: tone)
            await MainActor.run {
                sampleText = result.text
                isProcessing = false
                resultMessage = result.usedAI ? "✨ Lapidado via Gemini (\(result.modelUsed ?? "AI"))" : "✦ Lapidado via Motor Local"
            }
        }
    }
}
