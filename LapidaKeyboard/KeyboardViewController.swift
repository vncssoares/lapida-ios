import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    
    private var hostingController: UIHostingController<AnyView>?
    
    // Estados reativos compartilhados com o SwiftUI
    private var isLoading: Bool = false {
        didSet { updateHostingView() }
    }
    private var activeTone: RewriteTone? = nil {
        didSet { updateHostingView() }
    }
    private var feedbackToast: String? = nil {
        didSet { updateHostingView() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardHosting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateHostingView()
    }
    
    private func setupKeyboardHosting() {
        let keyboardView = createKeyboardView()
        let host = UIHostingController(rootView: AnyView(keyboardView))
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        
        addChild(host)
        view.addSubview(host.view)
        
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        host.didMove(toParent: self)
        self.hostingController = host
    }
    
    private func updateHostingView() {
        hostingController?.rootView = AnyView(createKeyboardView())
    }
    
    private func createKeyboardView() -> some View {
        KeyboardView(
            onInsertText: { [weak self] text in
                self?.textDocumentProxy.insertText(text)
            },
            onDeleteBackward: { [weak self] in
                self?.textDocumentProxy.deleteBackward()
            },
            onNextKeyboard: { [weak self] in
                self?.advanceToNextInputMode()
            },
            onToneSelected: { [weak self] tone in
                self?.handleToneSelection(tone)
            },
            isLoading: Binding(get: { self.isLoading }, set: { self.isLoading = $0 }),
            activeTone: Binding(get: { self.activeTone }, set: { self.activeTone = $0 }),
            feedbackToast: Binding(get: { self.feedbackToast }, set: { self.feedbackToast = $0 })
        )
    }
    
    // MARK: - Lógica de Lapidação e Substituição de Texto
    
    private func handleToneSelection(_ tone: RewriteTone) {
        guard !isLoading else { return }
        
        // 1. Captura do contexto de texto do campo alvo
        let beforeContext = textDocumentProxy.documentContextBeforeInput ?? ""
        let afterContext = textDocumentProxy.documentContextAfterInput ?? ""
        var targetText = (beforeContext + afterContext).trimmingCharacters(in: .whitespacesAndNewlines)
        var isFromClipboard = false
        
        // Se o campo estiver vazio, tenta ler o clipboard
        if targetText.isEmpty {
            if let pasteboardText = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines), !pasteboardText.isEmpty {
                targetText = pasteboardText
                isFromClipboard = true
            }
        }
        
        if targetText.isEmpty {
            showToast("Digite ou cole algo primeiro ✏️")
            triggerHapticNotification(.warning)
            return
        }
        
        // 2. Inicia o processamento
        self.isLoading = true
        self.activeTone = tone
        self.feedbackToast = nil
        
        Task { [weak self] in
            guard let self = self else { return }
            
            let result = await GeminiService.shared.rewrite(text: targetText, tone: tone)
            
            await MainActor.run {
                self.isLoading = false
                self.activeTone = nil
                
                let finalText = result.text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !finalText.isEmpty else {
                    self.showToast("Não foi possível lapidar ⚠️")
                    self.triggerHapticNotification(.error)
                    return
                }
                
                // 3. Substituição limpa do texto
                if !isFromClipboard && !beforeContext.isEmpty {
                    // Apaga o texto anterior antes do cursor
                    for _ in 0..<beforeContext.count {
                        self.textDocumentProxy.deleteBackward()
                    }
                }
                
                // Insere o texto lapidado
                self.textDocumentProxy.insertText(finalText)
                
                // Se veio do clipboard, atualiza o clipboard também para comodidade
                if isFromClipboard {
                    UIPasteboard.general.string = finalText
                }
                
                // Salva referência do último texto
                SharedStorage.shared.lastRewrittenText = finalText
                
                self.showToast("✦ Texto lapidado!")
                self.triggerHapticNotification(.success)
            }
        }
    }
    
    private func showToast(_ message: String) {
        self.feedbackToast = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            if self?.feedbackToast == message {
                self?.feedbackToast = nil
            }
        }
    }
    
    private func triggerHapticNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        if SharedStorage.shared.isHapticEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
