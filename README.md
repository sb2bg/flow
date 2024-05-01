# Flow

![Flow Logo](https://raw.githubusercontent.com/sb2bg/flow/173e35f29e44f4cd5431b094e71871f3aacf4568/macos/Runner/Assets.xcassets/AppIcon.appiconset/256-mac.png?token=GHSAT0AAAAAACD24Q4YXCCTTOVNDZYRCUWAZRSS3YQ)

Flow is a simple and easy to use GUI for Ollama LLMs (Language Model Models) such as Llama3, Mistral, and even multimodal models such as Llava. For a full list of supported models, see the [Ollama Website](https://ollama.com/models).

## Features

- **Easy to use**: Flow is designed to be as simple as possible, with a clean and intuitive interface.
- **Anonymous**: Flow does not collect any personal data, and does not require an account to use. Chats are persisted locally in memory, not stored on disk, and are cleared when the app is closed.
- **Cross-platform**: Flow is available on Windows, macOS, and Linux.
- **Multimodal**: Flow supports multimodal models such as Llava, which can use vision processing and language to generate responses.

## Installation

1. **Ollama is required** to use Flow. You can download it from the [Ollama Website](https://ollama.com/download).
2. **Clone the repository**:
   ```sh
   git clone https://github.com/sb2bg/flow
   cd flow
   ```
3. **Install dependencies**:
   ```sh
    flutter pub get
   ```
4. **Run** or **Build** the app:

   - Run

   ```sh
    flutter run
   ```

   - Build

   ```sh
   flutter build <platform>
   ```

   Replace `<platform>` with the platform you want to build for (`windows`, `macos`, `linux`, etc.).

## Usage

1. **Install a model**: Use ollama to install a model. For example, to install the Llama3 model, run:
   ```sh
   ollama run llama3
   ```
   For a full list of supported models, see the [Ollama Website](https://ollama.com/models).
2. **Load Flow**: Open Flow and select the model you installed. Then, start chatting!

## To-Do

- [ ] Make incognito mode actually do something
- [ ] Add support for persisting chats to disk
- [ ] Add support to have multiple concurrent chats with the same model without having to clear the chat to start a new one

## License

Flow is licensed under the [MIT License](https://github.com/sb2bg/flow/blob/main/LICENSE).

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.
