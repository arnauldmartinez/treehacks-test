import SwiftUI
import Combine

struct ChatsPlaceholderView: View {
    @StateObject private var vm = ChatsViewModel()
    @State private var experts: [Expert] = Expert.sample
    @State private var selected: Expert? = nil
    @State private var draft: String = ""
    @State private var isSidebarCollapsed: Bool = false
    @StateObject private var drKhanVM = DrKhanInlineVM()

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                if !isSidebarCollapsed {
                    // Left sidebar with expert tiles
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(experts) { expert in
                                Button {
                                    selected = expert
                                } label: {
                                    ExpertTile(expert: expert, isSelected: selected?.id == expert.id)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                        .padding(.top, 80)
                    }
                    .frame(width: 280)
                    .background(.ultraThinMaterial)

                    Divider()
                }

                // Main chat area
                Group {
                    if let expert = selected {
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text(expert.displayName)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Theme.text)
                                Spacer()
                                Text(expert.degree)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.sub)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .padding(.top, isSidebarCollapsed ? 60 : 0)

                            Divider()

                            if expert.lastName == "Khan" {
                                VStack(spacing: 0) {
                                    // Dr. Khan live chat (server-backed)
                                    GeometryReader { chatGeo in
                                        ScrollViewReader { proxy in
                                            ScrollView {
                                                LazyVStack(alignment: .leading, spacing: 12) {
                                                    ForEach(drKhanVM.messages) { msg in
                                                        ChatBubbleRow(message: msg)
                                                            .padding(.horizontal, 18)
                                                    }
                                                    Color.clear
                                                        .frame(height: chatGeo.size.height * 0.10)
                                                        .id("bottom")
                                                }
                                                .padding(.top, 12)
                                                .padding(.bottom, 12)
                                            }
                                            .mask(
                                                LinearGradient(
                                                    stops: [
                                                        .init(color: .black, location: 0.0),
                                                        .init(color: .black, location: 0.90),
                                                        .init(color: .clear, location: 1.0)
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .onChange(of: drKhanVM.messages.count) { _ in
                                                withAnimation(.easeOut(duration: 0.2)) {
                                                    proxy.scrollTo("bottom", anchor: .bottom)
                                                }
                                            }
                                            .onAppear {
                                                DispatchQueue.main.async {
                                                    proxy.scrollTo("bottom", anchor: .bottom)
                                                }
                                            }
                                        }
                                    }

                                    HStack(spacing: 12) {
                                        TextField("Type a message…", text: $drKhanVM.draft)
                                            .textFieldStyle(.plain)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(Color.white.opacity(0.85))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Theme.tileStroke, lineWidth: 1)
                                            )

                                        Button { drKhanVM.send() } label: {
                                            Image(systemName: "paperplane.fill")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundStyle(.white)
                                                .padding(10)
                                                .background(Circle().fill(Theme.accent))
                                        }
                                    }
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 10)
                                    .background(.ultraThinMaterial)
                                    .padding(.bottom, 80)
                                }
                                .task { drKhanVM.onAppear() }
                                .onDisappear { drKhanVM.onDisappear() }
                            } else {
                                // Existing local chat UI (unchanged)
                                // Chat messages (grow from top) with protected bottom 10%
                                GeometryReader { chatGeo in
                                    ScrollViewReader { proxy in
                                        ScrollView {
                                            LazyVStack(alignment: .leading, spacing: 12) {
                                                ForEach(vm.messages(for: expert.id)) { msg in
                                                    ChatBubbleRow(message: msg)
                                                        .padding(.horizontal, 18)
                                                }
                                                Color.clear
                                                    .frame(height: chatGeo.size.height * 0.10)
                                                    .id("bottom")
                                            }
                                            .padding(.top, 12)
                                            .padding(.bottom, 12)
                                        }
                                        .mask(
                                            LinearGradient(
                                                stops: [
                                                    .init(color: .black, location: 0.0),
                                                    .init(color: .black, location: 0.90),
                                                    .init(color: .clear, location: 1.0)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .onChange(of: vm.count(for: expert.id)) { _ in
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                proxy.scrollTo("bottom", anchor: .bottom)
                                            }
                                        }
                                        .onAppear {
                                            DispatchQueue.main.async {
                                                proxy.scrollTo("bottom", anchor: .bottom)
                                            }
                                        }
                                    }
                                }

                                HStack(spacing: 12) {
                                    TextField("Type a message…", text: $draft)
                                        .textFieldStyle(.plain)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(Color.white.opacity(0.85))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(Theme.tileStroke, lineWidth: 1)
                                        )

                                    Button {
                                        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard !text.isEmpty, let expert = selected else { return }
                                        vm.appendUser(text: text, to: expert.id)
                                        draft = ""
                                    } label: {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .padding(10)
                                            .background(Circle().fill(Theme.accent))
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial)
                                .padding(.bottom, 80)
                            }
                        }
                    } else {
                        VStack(spacing: 10) {
                            Text("Select an expert to start a chat")
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.sub)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .themedBackground()
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSidebarCollapsed.toggle()
                        }
                    } label: {
                        Image(systemName: isSidebarCollapsed ? "sidebar.right" : "sidebar.left")
                    }
                    .accessibilityLabel(isSidebarCollapsed ? "Show sidebar" : "Hide sidebar")
                }
            }
        }
    }
}
// MARK: - Expert Model

private struct Expert: Identifiable, Hashable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let degree: String

    var displayName: String { "Dr. \(lastName)" }

    static let sample: [Expert] = [
        Expert(firstName: "Amelia", lastName: "Cooper", degree: "M.D."),
        Expert(firstName: "Jacob", lastName: "Schuster", degree: "J.D."),
        Expert(firstName: "Arnauld", lastName: "Martinez", degree: "Ph.D."),
        Expert(firstName: "Priya", lastName: "Patel", degree: "J.D."),
        Expert(firstName: "Minh", lastName: "Nguyen", degree: "M.D."),
        Expert(firstName: "Lena", lastName: "Khan", degree: "L.C.S.W."),
    ]
}

// MARK: - Tile View

private struct ExpertTile: View {
    let expert: Expert
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.accent)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(expert.lastName.prefix(1)))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(expert.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Text(expert.degree)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.sub)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.tileFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Theme.accent : Theme.tileStroke, lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: Theme.tileShadow, radius: 6, x: 0, y: 2)
        )
    }
}

private struct ChatBubbleRow: View {
    let message: ChatsMessage
    var body: some View {
        HStack(spacing: 0) {
            if message.role == .assistant {
                // Left side (Dr. Khan/server)
                bubble
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: .leading)
                Spacer(minLength: 0)
            } else {
                // Right side (user)
                Spacer(minLength: 0)
                bubble
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .assistant ? .leading : .trailing)
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.content)
                .font(.system(size: 15))
                .foregroundStyle(Theme.text)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(message.role == .assistant ? Color(red: 0.90, green: 0.88, blue: 0.98) : Theme.accent)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.tileStroke, lineWidth: 1)
                )
                .shadow(color: Theme.tileShadow, radius: 6, x: 0, y: 2)
        )
    }
}

// MARK: - Inline Dr. Khan VM (server-backed, minimal deps)
@MainActor
final class DrKhanInlineVM: ObservableObject {
    @Published private(set) var messages: [ChatsMessage] = []
    @Published var draft: String = ""
    @Published private(set) var isConnected: Bool = false
    private var socket: URLSessionWebSocketTask?
    private var receiveLoopTask: Task<Void, Never>?
    private var pingTask: Task<Void, Never>?

    private var pollTask: Task<Void, Never>?
    private var seenAssistantMessageIDs = Set<String>()

    private let userId = "1"
    private let restBase = URL(string: "http://10.19.180.135:8000")!
    private let wsURL = URL(string: "ws://10.19.180.135:8000/ws")!
    private func log(_ items: Any...) { print("[DrKhanVM]", items.map { "\($0)" }.joined(separator: " ")) }

    private func ensureConnected() {
        if socket == nil { connectWebSocket() }
        if pollTask == nil { startPolling() }
        if messages.isEmpty { Task { await loadHistory() } }
    }

    func onAppear() {
        log("onAppear: loadHistory + connectWebSocket + startPolling")
        Task { await loadHistory() }
        connectWebSocket()
        startPolling()
    }

    func onDisappear() {
        log("onDisappear: disconnectWebSocket + stopPolling")
        disconnectWebSocket()
        stopPolling()
    }

    func send() {
        ensureConnected()
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // optimistic append
        messages.append(ChatsMessage(role: .user, content: text))
        log("Appended user message (optimistic):", text)
        draft = ""

        Task { await postMessage(text) }
    }

    // MARK: - REST
    private func loadHistory() async {
        do {
            let url = restBase.appendingPathComponent("users").appendingPathComponent(userId).appendingPathComponent("chat")
            print("GET history:", url.absoluteString)
            let (data, _) = try await URLSession.shared.data(from: url)
            let history = try JSONDecoder().decode([APIChatMessage].self, from: data)
            messages = history.map { APIChatMessage in
                ChatsMessage(role: APIChatMessage.sender == "user" ? .user : .assistant, content: APIChatMessage.text)
            }
            // Track assistant messages we've already seen to avoid duplicates when polling
            seenAssistantMessageIDs = Set(history.filter { $0.sender != "user" }.map { $0.id })
            print("Loaded history count:", messages.count)
            log("Initialized seenAssistantMessageIDs count:", seenAssistantMessageIDs.count)
        } catch {
            print("History error:", error)
        }
    }

    private func postMessage(_ text: String) async {
        do {
            let url = restBase.appendingPathComponent("users").appendingPathComponent(userId).appendingPathComponent("chat")
            print("POST message to:", url.absoluteString, "text:", text)
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body = try JSONSerialization.data(withJSONObject: ["sender": "user", "text": text])
            req.httpBody = body
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse { log("POST status:", http.statusCode) }
            if let bodyStr = String(data: data, encoding: .utf8), !bodyStr.isEmpty { log("POST response body:", bodyStr) }
        } catch {
            print("Send error:", error)
        }
    }

    // MARK: - Polling for new messages via REST
    private func startPolling() {
        guard pollTask == nil else { return }
        log("startPolling: started")
        pollTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                await self.pollOnce()
                // Poll every 2 seconds; adjust as needed
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }

    private func stopPolling() {
        log("stopPolling: stopping")
        pollTask?.cancel()
        pollTask = nil
    }

    private func pollOnce() async {
        do {
            let url = restBase.appendingPathComponent("users").appendingPathComponent(userId).appendingPathComponent("chat")
            log("Polling GET:", url.absoluteString)
            let (data, _) = try await URLSession.shared.data(from: url)
            if let raw = String(data: data, encoding: .utf8) { log("Polling raw response:", raw) }
            let all = try JSONDecoder().decode([APIChatMessage].self, from: data)
            log("Polling decoded messages count:", all.count)
            // Only consider non-user (server) messages that we haven't seen yet
            let newAssistant = all.filter { $0.sender != "user" && !seenAssistantMessageIDs.contains($0.id) }
            log("New assistant messages found:", newAssistant.count)
            guard !newAssistant.isEmpty else { return }
            // Append in order received
            for msg in newAssistant {
                seenAssistantMessageIDs.insert(msg.id)
                messages.append(ChatsMessage(role: .assistant, content: msg.text))
                log("Appended assistant message from poll:", msg.id, msg.sender, msg.text)
            }
        } catch {
            log("Poll error:", String(describing: error))
        }
    }

    // MARK: - WebSocket
    private func connectWebSocket() {
        guard socket == nil else { return }
        let task = URLSession.shared.webSocketTask(with: wsURL)
        socket = task
        task.resume()
        print("WS connecting to: \(wsURL)")
        isConnected = true
        log("WS set isConnected = true")

        // keepalive ping every 30s
        pingTask = Task { [weak self] in
            while let socket = self?.socket, !Task.isCancelled {
                socket.sendPing { error in
                    if let error {
                        print("WS ping error:", error)
                    }
                }
                try? await Task.sleep(nanoseconds: 30 * 1_000_000_000)
            }
        }

        receiveLoopTask = Task { [weak self] in
            await self?.receiveLoop()
        }
    }

    private func disconnectWebSocket() {
        log("WS disconnect requested")
        pingTask?.cancel(); pingTask = nil
        receiveLoopTask?.cancel()
        receiveLoopTask = nil
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
        isConnected = false
    }

    private func receiveLoop() async {
        guard let socket else { return }
        while !Task.isCancelled {
            do {
                let message = try await socket.receive()
                log("WS received frame")
                switch message {
                case .string(let str):
                    log("WS frame type: string, length:", str.count)
                    if let data = str.data(using: .utf8) { handleIncoming(data: data) }
                case .data(let data):
                    log("WS frame type: data, length:", data.count)
                    handleIncoming(data: data)
                @unknown default:
                    log("WS frame type: unknown")
                    break
                }
            } catch {
                log("WS receive error:", String(describing: error))
                break
            }
        }
        log("WS receive loop ended")
    }

    private func handleIncoming(data: Data) {
        do {
            let env = try JSONDecoder().decode(WSChatEnvelope.self, from: data)
            guard env.type == "chat", env.user_id == userId else {
                log("WS payload ignored: type/user mismatch")
                return
            }
            // Ignore echo of our own user messages; we already append optimistically
            if env.message.sender == "user" {
                log("WS echo ignored for user message id:", env.message.id)
                return
            }
            log("WS chat message id:", env.message.id, "sender:", env.message.sender, "text:", env.message.text)
            messages.append(ChatsMessage(role: .assistant, content: env.message.text))
            log("Appended message from WS with role:", "assistant")
            seenAssistantMessageIDs.insert(env.message.id)
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            log("WS decode error:", String(describing: error), "raw:", raw)
        }
    }

    // MARK: - Models (local to VM)
    private struct APIChatMessage: Codable {
        let id: String
        let sender: String
        let text: String
        let timestamp: String
    }

    private struct WSChatEnvelope: Codable {
        let type: String
        let user_id: String
        let message: APIChatMessage
    }
}

