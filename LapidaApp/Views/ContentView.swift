import SwiftUI

public struct ContentView: View {
    @State private var apiKeyInput: String = ""
    @State private var isSaved: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Fundo escuro imersivo estilo iOS Dark Mode
            Color(hex: "#0A0A0C")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Cabeçalho Oficial
                    HeaderView()
                    
                    // Card 1: Chave de API Google Gemini
                    ApiKeyCard(apiKeyInput: $apiKeyInput, isSaved: $isSaved)
                    
                    // Card 2: Guia de Ativação do Teclado
                    StepCard()
                    
                    // Card 3: Área de Teste
                    TestAreaCard()
                    
                    // Rodapé informativo
                    VStack(spacing: 4) {
                        Text("Lapida para iOS • v1.0.0")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(hex: "#636366"))
                        
                        Text("Privacidade em primeiro lugar: seus dados não são salvos em servidores próprios.")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#48484A"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
        }
        .onAppear {
            loadInitialSettings()
        }
    }
    
    private func loadInitialSettings() {
        let savedKey = SharedStorage.shared.geminiApiKey
        apiKeyInput = savedKey
        isSaved = !savedKey.isEmpty
    }
}
