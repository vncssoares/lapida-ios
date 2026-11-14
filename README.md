# 💎 Lapida para iOS (iPhone)

Aplicativo nativo e **Extensão de Teclado Personalizado (Custom Keyboard Extension)** em **Swift** e **SwiftUI** para iPhone, trazendo a inteligência artificial do Lapida para qualquer mensageiro do iOS (WhatsApp, Telegram, Instagram Direct, Mensagens, E-mails e Notas).

---

## 📱 Por que uma Extensão de Teclado no iOS?

Ao contrário do Android, o sistema operacional da Apple (**iOS**) impõe sandboxing restrito de segurança e **não permite** overlays flutuantes arbitrários nem serviços de acessibilidade que leiam ou modifiquem o conteúdo de outros aplicativos.

A forma oficial e mais poderosa de trazer assistência de escrita com IA para todo o ecossistema iOS é por meio de uma **Custom Keyboard Extension (`UIInputViewController`)**:
- Funciona perfeitamente em **todos** os apps do iPhone.
- Exibe uma barra superior integrada com os **5 botões de lapidação**.
- Lê o texto digitado pelo usuário (`textDocumentProxy`), processa via **Google Gemini** e substitui diretamente no campo ativo.

---

## 🎨 Identidade Visual e os 5 Tons de Lapidação

Na barra superior do teclado e na interface escura minimalista (`#1C1C1E`), estão presentes as 5 ações com ícones e cores oficiais:

| Tom | Cor | Ícone | Função |
| :--- | :--- | :---: | :--- |
| **Corrigir e Lapidar** | `#007AFF` (Azul) | ✦ | Corrige ortografia, acentuação, "mais/mas", abreviações e fluidez. |
| **Resumir** | `#FF9500` (Laranja) | 📄 | Condensa fatos e pontos principais sem omitir o desenvolvimento. |
| **Complementar** | `#34C759` (Verde) | ↗ | Enriquece o vocabulário e aprofunda os argumentos. |
| **Mais Profissional** | `#636366` (Cinza) | ⬛ | Reescreve com vocabulário corporativo, formal e cortês. |
| **Mais Amigável** | `#FF3B30` (Vermelho) | ♥ | Reescreve com tom caloroso, empático e emojis naturais. |

---

## 📂 Estrutura do Projeto

```
PROJETO 02 - LAPIDA IOS/
├── .github/
│   └── workflows/
│       └── ios-build.yml           # Workflow que compila o .ipa no macOS na nuvem
├── Lapida.xcodeproj/
│   └── project.pbxproj             # Projeto Xcode 15/16 com targets App e Extension
├── LapidaApp/                      # Aplicativo Principal (SwiftUI)
│   ├── App/
│   │   └── LapidaApp.swift         # Entry point do App
│   ├── Views/
│   │   ├── ContentView.swift       # Tela principal escura com cartões e área de teste
│   │   └── Components/
│   │       ├── HeaderView.swift    # Logo minimalista de lápis azul
│   │       ├── ApiKeyCard.swift    # Configuração da chave de API
│   │       ├── StepCard.swift      # Guia visual de ativação do teclado
│   │       └── TestAreaCard.swift  # Área interativa de testes
│   ├── Services/
│   │   └── SharedStorage.swift     # UserDefaults compartilhado (App Groups)
│   ├── Models/
│   │   └── RewriteTone.swift       # Enum dos 5 tons e prompts do Gemini
│   ├── Assets.xcassets/            # Ícones e cores
│   ├── LapidaApp.entitlements      # App Group: group.com.lapida.app
│   └── Info.plist
├── LapidaKeyboard/                 # Extensão de Teclado (UIInputViewController)
│   ├── KeyboardViewController.swift# Controle do ciclo de vida e textDocumentProxy
│   ├── Views/
│   │   ├── LapidaActionToolbar.swift # Barra de ferramentas com os 5 botões
│   │   └── KeyboardView.swift      # Teclado QWERTY PT-BR estilo iOS Dark Mode
│   ├── Services/
│   │   ├── GeminiService.swift     # Chamada HTTP assíncrona ao Google Gemini
│   │   ├── LocalRewriteEngine.swift# Motor inteligente local para fallback offline
│   │   └── SharedStorage.swift     # Leitura da API Key configurada no App
│   ├── Models/
│   │   └── RewriteTone.swift
│   ├── LapidaKeyboard.entitlements # App Group compartilhado
│   └── Info.plist                  # RequestsOpenAccess = YES
├── simulador_ios.html              # Protótipo funcional para testar no navegador
└── README.md
```

---

## 🚀 Como Compilar o `.ipa` no Windows via GitHub Actions

Você não precisa de um computador Mac para gerar o aplicativo iOS instalável:

1. Suba esta pasta para um repositório no seu **GitHub** (`git init`, `git add .`, `git commit`, `git push`).
2. Acesse a aba **Actions** no seu repositório do GitHub.
3. O workflow `.github/workflows/ios-build.yml` será disparado automaticamente em uma máquina `macos-14` da nuvem com Xcode.
4. Ao término da compilação (cerca de 2 minutos), baixe o arquivo **`Lapida.ipa`** na seção **Artifacts**.

### Como Instalar o `.ipa` no iPhone:
- **Sideloadly (Windows/Mac):** Conecte o iPhone via cabo, selecione o arquivo `Lapida.ipa`, insira seu Apple ID e instale diretamente.
- **AltStore:** Instale pelo AltServer no Windows.
- **TrollStore:** Instalação direta para iOS compatíveis.

---

## ⚙️ Como Ativar o Teclado no iPhone

Após instalar o aplicativo no seu iPhone:

1. Abra o **Lapida**, insira sua **API Key do Google Gemini** e toque em **Salvar Chave no Teclado**.
2. Abra os **Ajustes** do iOS > **Geral** > **Teclado** > **Teclados**.
3. Toque em **Adicionar Novo Teclado...** e selecione **Lapida**.
4. Toque em **Lapida** na lista e ative **Permitir Acesso Total** *(necessário para o teclado poder acessar a internet e chamar a IA)*.
5. Pronto! Ao digitar em qualquer aplicativo (WhatsApp, Instagram, Telegram), toque no ícone de globo 🌐 para alternar para o teclado Lapida.

---

## 🌐 Teste Imediato no Navegador (Windows)

Abra o arquivo [`simulador_ios.html`](file:///c:/Users/vinis/Downloads/PROJETO%2002%20-%20REESCRITA%20IA/simulador_ios.html) em qualquer navegador (Chrome, Edge, Firefox). Ele replica perfeitamente o iPhone com WhatsApp e o Teclado Lapida funcionando em tempo real.
