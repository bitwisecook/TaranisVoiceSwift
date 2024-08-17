import SwiftUI

class LogManager: ObservableObject {
    static let shared = LogManager()
    @Published var logs: [String] = []

    private init() {}

    func addLog(_ message: String) {
        DispatchQueue.main.async {
            let newLogs = message.split(
                separator: "\n", omittingEmptySubsequences: false
            ).map(String.init)
            self.logs.append(contentsOf: newLogs)
        }
    }

    func getAllLogs() -> String {
        return logs.joined(separator: "\n")
    }
}

struct LogView: View {
    @EnvironmentObject var logManager: LogManager
    @State private var showCopiedAlert = false

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(logManager.logs.indices, id: \.self) { index in
                        Text(logManager.logs[index])
                            .font(.system(.body, design: .monospaced))
                    }
                }
                .padding()
            }
        }
        .alert("Logs Copied", isPresented: $showCopiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All logs have been copied to the clipboard.")
        }
        HStack {
            Button("Copy Logs") {
                copyLogs()
            }
            .keyboardShortcut("C", modifiers: [.command, .shift])
            .padding()

            Spacer()

            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .padding()
        }
    }

    private func copyLogs() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(logManager.getAllLogs(), forType: .string)
        showCopiedAlert = true
    }
}
