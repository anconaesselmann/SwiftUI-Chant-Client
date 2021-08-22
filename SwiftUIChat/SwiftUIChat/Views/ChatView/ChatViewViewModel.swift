//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation
import Combine

class ChatViewViewModel: ObservableObject {
    @Published var viewData: [MessageViewData] = []
    @Published var status: SocketNetworking.Status = .notConnected
    @Published var chatPartnerIsTyping = false
    @Published var userIsTyping = false {
        didSet {
            networking.updateIsTyping(userIsTyping)
            print(userIsTyping)
        }
    }
    @Published var message: String = ""

    let loginManager: LoginManager

    private let networking: SocketNetworkingProtocol
    private let messageHistory: HistoryProtocol

    private var subscribed = false
    
    private var subscriptions = Set<AnyCancellable>()

    var timer: Timer?

    init(networking: SocketNetworkingProtocol = SocketNetworking(), messageHistory: HistoryProtocol = MessageHistory(), loginManager: LoginManager) {
        self.networking = networking
        self.messageHistory = messageHistory
        self.loginManager = loginManager

        $message.sink { [weak self] message in
            guard !message.isEmpty else {
                return
            }
            if let userIsTyping = self?.userIsTyping, userIsTyping == false {
                self?.userIsTyping = true
            }
            self?.timer?.invalidate()
            self?.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                self?.userIsTyping = false
            }
        }.store(in: &subscriptions)
    }

    func subscribe() {
        guard !subscribed else {
            return
        }
        subscribed = true

        messageHistory.history.sink { [weak self] history in
            guard let sender = self?.loginManager.token?.userId else {
                return
            }
            self?.viewData = history.map { $0.viewData(given: sender) }
        }.store(in: &subscriptions)

        networking.status.sink { [weak self] status in
            self?.status = status
        }.store(in: &subscriptions)

        networking.messageStatus.sink { [weak self] status in
            switch status {
            case .received(let message):
                self?.chatPartnerIsTyping = false
                self?.messageHistory.add(message: message)
            case .sent(let message):
                self?.messageHistory.add(message: message)
            case .isTyping(let isTyping):
                self?.chatPartnerIsTyping = isTyping
            case .messageRead(let messageId):
                self?.messageHistory.messageRead(id: messageId)
            }
        }.store(in: &subscriptions)
    }

    func send(message body: String) {
        let uuid = UUID()
        let date = Date()
        guard let sender = loginManager.token?.userId else {
            return
        }
        let message = Message(uuid: uuid, date: date, sender: sender, body: body)
        networking.send(message: message)
    }

    func logout() {
        loginManager.logout()
    }

    deinit {
        networking.stopChatSession()
    }
}
