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

## 🛠️ Arquitetura e Geração com XcodeGen (`project.yml`)

O projeto utiliza **XcodeGen** (`project.yml`), eliminando qualquer inconsistência de caminhos ou corrupção no arquivo `project.pbxproj`:
- Target **`LapidaApp`**: Aplicativo principal em SwiftUI (iOS 16+)
- Target **`LapidaKeyboard`**: Extensão de teclado com `embed: true` no app
- Entitlements com **App Groups** (`group.com.lapida.app`) para compartilhamento da API Key entre o App e o Teclado

---

## 🚀 Como Compilar o `.ipa` no Windows via GitHub Actions

Você não precisa de um computador Mac para gerar o aplicativo iOS instalável:

1. Suba esta pasta para um repositório no seu **GitHub** (`git init`, `git add .`, `git commit`, `git push`).
2. Acesse a aba **Actions** no seu repositório do GitHub.
3. O workflow `.github/workflows/ios-build.yml` instala o `xcodegen`, gera o projeto Xcode nativo e compila tudo com `xcodebuild`.
4. Ao término da compilação (cerca de 2 minutos), baixe o arquivo **`Lapida-iOS-v1.0-IPA`** (arquivo `Lapida.ipa`) na seção **Artifacts**.

### Como Instalar o `.ipa` no iPhone:
- **Sideloadly (Windows/Mac):** Conecte o iPhone via cabo, selecione o arquivo `Lapida.ipa`, insira seu Apple ID e instale diretamente.
- **AltStore:** Instale pelo AltServer no Windows.
- **TrollStore:** Instalação direta para iOS compatíveis.

---

## ⚙️ Como Ativar o Teclado no iPhone

Após instalar o aplicativo no seu iPhone:

1. Abra o **Lapida**, insira sua **API Key do Google Gemini** e toque em **Salvar Chave no Teclado**.
2. Abra os **Ajustes** do iPhone > **Geral** > **Teclado** > **Teclados**.
3. Toque em **Adicionar Novo Teclado...** e selecione **Lapida**.
4. Toque em **Lapida** na lista e ative **Permitir Acesso Total** *(necessário para o teclado poder acessar a internet e chamar a IA)*.
5. **Pronto!** Ao digitar em qualquer aplicativo (WhatsApp, Instagram, Telegram), toque no ícone de globo 🌐 para alternar para o teclado Lapida.

---

## 🌐 Teste Imediato no Navegador (Windows)

Abra o arquivo [`simulador_ios.html`](file:///c:/Users/vinis/Downloads/PROJETO%2002%20-%20LAPIDA%20IOS/simulador_ios.html) em qualquer navegador (Chrome, Edge, Firefox). Ele replica perfeitamente o iPhone com WhatsApp e o Teclado Lapida funcionando em tempo real.
