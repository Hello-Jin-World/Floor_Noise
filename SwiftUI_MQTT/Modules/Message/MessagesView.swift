import SwiftUI

struct MessagesView: View {
    @StateObject var mqttManager = MQTTManager.shared()
    var body: some View {
        NavigationView {
            MessageView()
        }
        .environmentObject(mqttManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesView()
    }
}

struct MessageView: View {
    @State private var topic: String = ""
    @State private var message: String = ""
    @EnvironmentObject private var mqttManager: MQTTManager
    @State private var storedMessages: [Int] = [] // 메시지를 저장할 새로운 상태


    var body: some View {

        VStack {
            ConnectionStatusBar(message: mqttManager.connectionStateMessage(), isConnected: mqttManager.isConnected())
            VStack {
                HStack {
                    MQTTTextField(placeHolderMessage: "구독할 주제를 입력하세요", isDisabled: !mqttManager.isConnected() || mqttManager.isSubscribed(), message: $topic)
                    Button(action: functionFor(state: mqttManager.currentAppState.appConnectionState)) {
                        Text(titleForSubscribButtonFrom(state: mqttManager.currentAppState.appConnectionState))
                            .font(.system(size: 14.0))
                    }.buttonStyle(BaseButtonStyle(foreground: .white, background: .green))
                        .frame(width: 100)
                        .disabled(!mqttManager.isConnected() || topic.isEmpty)
                }
                Text("실시간 진동량")
                MessageHistoryTextView(text: $mqttManager.currentAppState.historyText)
                    .onAppear {
                        // 뷰가 나타날 때 저장된 메시지를 로드
                        storedMessages = loadMessages()
                    }
                    .onChange(of: mqttManager.currentAppState.historyText) { newHistoryText in
                        // historyText가 변경될 때마다 저장된 메시지 업데이트
                        storeMessage(newHistoryText)
                    }
                    .frame(height: 150)
            }.padding(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7))
            
            Spacer()
        }
        
        .navigationTitle("층간소음")
        .navigationBarItems(trailing: NavigationLink(
            destination: SettingsView(brokerAddress: mqttManager.currentHost() ?? ""),
            label: {
                Image(systemName: "gear")
            }))
        
    }
    
    private func storeMessage(_ newMessage: String) {
    // newMessage를 Int로 변환하되 변환이 가능한 경우에만
        if let intValue = Int(newMessage) {
            storedMessages.append(intValue)
            saveMessages()
        }
    }
    
    private func subscribe(topic: String) {
        mqttManager.subscribe(topic: topic)
    }

    private func usubscribe() {
        mqttManager.unSubscribeFromCurrentTopic()
    }

    private func send(message: String) {
        let finalMessage = "SwiftUIIOS says: \(message)"
        mqttManager.publish(with: finalMessage)
        self.message = ""
    }

    private func titleForSubscribButtonFrom(state: MQTTAppConnectionState) -> String {
        switch state {
        case .connected, .connectedUnSubscribed, .disconnected, .connecting:
            return "구독"
        case .connectedSubscribed:
            return "구독 취소"
        }
    }

    private func functionFor(state: MQTTAppConnectionState) -> () -> Void {
        switch state {
        case .connected, .connectedUnSubscribed, .disconnected, .connecting:
            return { subscribe(topic: topic) }
        case .connectedSubscribed:
            return { usubscribe() }
        }
    }
    
    private func loadMessages() -> [Int] {
        return UserDefaults.standard.stringArray(forKey: "StoredMessages") as? [Int] ?? []
    }

    private func saveMessages() {
        UserDefaults.standard.set(storedMessages, forKey: "StoredMessages")
    }
    
}
