import SwiftUI

/// Guia visual passo a passo para habilitar o teclado Lapida no iOS
public struct StepCard: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(hex: "#34C759").opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "keyboard.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "#34C759"))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Como Ativar no iPhone")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Configuração rápida em 3 etapas")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#8E8E93"))
                }
            }
            
            VStack(spacing: 12) {
                stepRow(
                    number: "1",
                    title: "Abra os Ajustes do iOS",
                    detail: "Acesse Ajustes > Geral > Teclado > Teclados."
                )
                
                stepRow(
                    number: "2",
                    title: "Adicione o Lapida",
                    detail: "Toque em Adicionar Novo Teclado... e escolha Lapida."
                )
                
                stepRow(
                    number: "3",
                    title: "Permita o Acesso Total",
                    detail: "Toque em Lapida na lista e ative Permitir Acesso Total (obrigatório para a IA acessar a internet)."
                )
            }
            
            // Botão de atalho para os Ajustes do iOS
            Button(action: openSettings) {
                HStack(spacing: 8) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                    
                    Text("Abrir Ajustes do iPhone")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 13))
                }
                .foregroundColor(Color(hex: "#007AFF"))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "#007AFF").opacity(0.12))
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
    
    private func stepRow(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 24, height: 24)
                
                Text(number)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#007AFF"))
            }
            .padding(.top, 1)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#8E8E93"))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
    }
    
    private func openSettings() {
        #if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #endif
    }
}
