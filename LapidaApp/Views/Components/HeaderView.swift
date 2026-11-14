import SwiftUI

/// Cabeçalho elegante com o ícone do lápis azul característico do Lapida
public struct HeaderView: View {
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            // Ícone do lápis azul vibrante estilo Apple
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#007AFF"), Color(hex: "#0055D4")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: Color(hex: "#007AFF").opacity(0.4), radius: 16, x: 0, y: 8)
                
                Image(systemName: "pencil")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.top, 8)
            
            VStack(spacing: 4) {
                Text("Lapida")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Assistente de Lapidação com IA para Teclado iOS")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#8E8E93"))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
