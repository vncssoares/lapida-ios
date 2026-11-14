import SwiftUI

public enum KeyboardMode {
    case letters
    case numbers
    case symbols
}

public struct KeyboardView: View {
    public let onInsertText: (String) -> Void
    public let onDeleteBackward: () -> Void
    public let onNextKeyboard: () -> Void
    public let onToneSelected: (RewriteTone) -> Void
    
    @Binding public var isLoading: Bool
    @Binding public var activeTone: RewriteTone?
    @Binding public var feedbackToast: String?
    
    @State private var isShiftActive: Bool = false
    @State private var isCapsLock: Bool = false
    @State private var mode: KeyboardMode = .letters
    
    public init(
        onInsertText: @escaping (String) -> Void,
        onDeleteBackward: @escaping () -> Void,
        onNextKeyboard: @escaping () -> Void,
        onToneSelected: @escaping (RewriteTone) -> Void,
        isLoading: Binding<Bool>,
        activeTone: Binding<RewriteTone?>,
        feedbackToast: Binding<String?>
    ) {
        self.onInsertText = onInsertText
        self.onDeleteBackward = onDeleteBackward
        self.onNextKeyboard = onNextKeyboard
        self.onToneSelected = onToneSelected
        self._isLoading = isLoading
        self._activeTone = activeTone
        self._feedbackToast = feedbackToast
    }
    
    // Layout QWERTY Português
    private let row1Letters = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
    private let row2Letters = ["a", "s", "d", "f", "g", "h", "j", "k", "l", "ç"]
    private let row3Letters = ["z", "x", "c", "v", "b", "n", "m"]
    
    // Layout Numérico
    private let row1Numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let row2Numbers = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
    private let row3Numbers = [".", ",", "?", "!", "'"]
    
    // Layout Símbolos
    private let row1Symbols = ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="]
    private let row2Symbols = ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"]
    private let row3Symbols = [".", ",", "?", "!", "'"]
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Barra Superior do Lapida
            LapidaActionToolbar(
                onSelectTone: { tone in
                    triggerHaptic()
                    onToneSelected(tone)
                },
                isLoading: isLoading,
                activeTone: activeTone,
                statusMessage: feedbackToast
            )
            
            // Toast flutuante de feedback quando aplicável
            if let toast = feedbackToast {
                Text(toast)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(hex: "#007AFF").opacity(0.9)))
                    .padding(.top, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // 2. Área de Teclas (Dark Mode Estilo iOS)
            VStack(spacing: 8) {
                switch mode {
                case .letters:
                    lettersView
                case .numbers:
                    numbersView
                case .symbols:
                    symbolsView
                }
                
                // Linha de Rodapé (123 / Globo / Espaço / Retorno)
                bottomRowView
            }
            .padding(.horizontal, 3)
            .padding(.top, 8)
            .padding(.bottom, 6)
            .background(Color(hex: "#121214"))
        }
    }
    
    // MARK: - Linhas de Letras
    
    private var lettersView: some View {
        VStack(spacing: 8) {
            // Linha 1
            HStack(spacing: 4) {
                ForEach(row1Letters, id: \.self) { char in
                    keyButton(label: displayChar(char), action: { handleInsert(displayChar(char)) })
                }
            }
            
            // Linha 2
            HStack(spacing: 4) {
                ForEach(row2Letters, id: \.self) { char in
                    keyButton(label: displayChar(char), action: { handleInsert(displayChar(char)) })
                }
            }
            
            // Linha 3 (Shift + Letras + Apagar)
            HStack(spacing: 5) {
                // Tecla Shift
                Button(action: toggleShift) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isShiftActive ? Color.white : Color(hex: "#3A3A3C"))
                        Image(systemName: isCapsLock ? "capslock.fill" : (isShiftActive ? "shift.fill" : "shift"))
                            .font(.system(size: 16))
                            .foregroundColor(isShiftActive ? .black : .white)
                    }
                    .frame(height: 42)
                    .frame(minWidth: 42)
                }
                
                HStack(spacing: 4) {
                    ForEach(row3Letters, id: \.self) { char in
                        keyButton(label: displayChar(char), action: { handleInsert(displayChar(char)) })
                    }
                }
                
                // Tecla Apagar
                Button(action: handleDelete) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(hex: "#3A3A3C"))
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(height: 42)
                    .frame(minWidth: 42)
                }
            }
        }
    }
    
    // MARK: - Linhas de Números
    
    private var numbersView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(row1Numbers, id: \.self) { char in
                    keyButton(label: char, action: { handleInsert(char) })
                }
            }
            HStack(spacing: 4) {
                ForEach(row2Numbers, id: \.self) { char in
                    keyButton(label: char, action: { handleInsert(char) })
                }
            }
            HStack(spacing: 5) {
                Button(action: { mode = .symbols }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#3A3A3C"))
                        Text("#+=")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(height: 42)
                    .frame(minWidth: 42)
                }
                
                HStack(spacing: 4) {
                    ForEach(row3Numbers, id: \.self) { char in
                        keyButton(label: char, action: { handleInsert(char) })
                    }
                }
                
                Button(action: handleDelete) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#3A3A3C"))
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(height: 42)
                    .frame(minWidth: 42)
                }
            }
        }
    }
    
    // MARK: - Linhas de Símbolos
    
    private var symbolsView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(row1Symbols, id: \.self) { char in
                    keyButton(label: char, action: { handleInsert(char) })
                }
            }
            HStack(spacing: 4) {
                ForEach(row2Symbols, id: \.self) { char in
                    keyButton(label: char, action: { handleInsert(char) })
                }
            }
            HStack(spacing: 5) {
                Button(action: { mode = .numbers }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#3A3A3C"))
                        Text("123")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(height: 42)
                    .frame(minWidth: 42)
                }
                
                HStack(spacing: 4) {
                    ForEach(row3Symbols, id: \.self) { char in
                        keyButton(label: char, action: { handleInsert(char) })
                    }
                }
                
                Button(action: handleDelete) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#3A3A3C"))
                        Image(systemName: "delete.left.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .frame(height: 42)
                    .frame(minWidth: 42)
                }
            }
        }
    }
    
    // MARK: - Linha de Rodapé
    
    private var bottomRowView: some View {
        HStack(spacing: 6) {
            // Alternador de modo (123 / ABC)
            Button(action: toggleMode) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#3A3A3C"))
                    Text(mode == .letters ? "123" : "ABC")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(width: 44, height: 42)
            }
            
            // Botão de Próximo Teclado (Globo)
            Button(action: {
                triggerHaptic()
                onNextKeyboard()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#3A3A3C"))
                    Image(systemName: "globe")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                .frame(width: 44, height: 42)
            }
            
            // Barra de Espaço
            Button(action: { handleInsert(" ") }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#48484A"))
                    Text("espaço")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(height: 42)
            }
            
            // Tecla de Retorno
            Button(action: { handleInsert("\n") }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5).fill(Color(hex: "#3A3A3C"))
                    Text("retorno")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .frame(width: 74, height: 42)
            }
        }
    }
    
    // MARK: - Construtores de Teclas
    
    private func keyButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: "#48484A"))
                Text(label)
                    .font(.system(size: 21, weight: .regular))
                    .foregroundColor(.white)
            }
            .frame(height: 42)
        }
    }
    
    // MARK: - Ações
    
    private func displayChar(_ char: String) -> String {
        (isShiftActive || isCapsLock) ? char.uppercased() : char.lowercased()
    }
    
    private func handleInsert(_ text: String) {
        triggerHaptic()
        onInsertText(text)
        if isShiftActive && !isCapsLock {
            isShiftActive = false
        }
    }
    
    private func handleDelete() {
        triggerHaptic()
        onDeleteBackward()
    }
    
    private func toggleShift() {
        triggerHaptic()
        if isShiftActive {
            if isCapsLock {
                isShiftActive = false
                isCapsLock = false
            } else {
                isCapsLock = true
            }
        } else {
            isShiftActive = true
        }
    }
    
    private func toggleMode() {
        triggerHaptic()
        if mode == .letters {
            mode = .numbers
        } else {
            mode = .letters
        }
    }
    
    private func triggerHaptic() {
        #if canImport(UIKit)
        if SharedStorage.shared.isHapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
        #endif
    }
}
