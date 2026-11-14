import SwiftUI

/// Barra de ferramentas superior dedicada ao Lapida dentro do teclado iOS
public struct LapidaActionToolbar: View {
    public let onSelectTone: (RewriteTone) -> Void
    public let isLoading: Bool
    public let activeTone: RewriteTone?
    public let statusMessage: String?
    
    public init(
        onSelectTone: @escaping (RewriteTone) -> Void,
        isLoading: Bool = false,
        activeTone: RewriteTone? = nil,
        statusMessage: String? = nil
    ) {
        self.onSelectTone = onSelectTone
        self.isLoading = isLoading
        self.activeTone = activeTone
        self.statusMessage = statusMessage
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Badge / Logo Lapida com lápis minimalista
            HStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#007AFF"), Color(hex: "#0055D4")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "pencil")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Lapida")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)
            .padding(.trailing, 2)
            
            Divider()
                .frame(height: 22)
                .background(Color.white.opacity(0.15))
            
            if isLoading {
                // Indicador de processamento discreto
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#007AFF")))
                        .scaleEffect(0.85)
                    
                    Text("Lapidando texto...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "#8E8E93"))
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                .transition(.opacity)
            } else {
                // 5 Botões de ação em ScrollView horizontal
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(RewriteTone.allCases) { tone in
                            LapidaTonePillButton(tone: tone) {
                                onSelectTone(tone)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .frame(height: 46)
        .background(Color(hex: "#1C1C1E"))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.white.opacity(0.12)),
            alignment: .bottom
        )
    }
}

/// Botão em formato pílula com ícone colorido para cada tom do Lapida
struct LapidaTonePillButton: View {
    let tone: RewriteTone
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // Quadrado arredondado com o ícone colorido característico
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(tone.color)
                        .frame(width: 22, height: 22)
                    
                    Text(tone.unicodeIcon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(tone.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
        }
        .buttonStyle(TonePillButtonStyle())
    }
}

struct TonePillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
