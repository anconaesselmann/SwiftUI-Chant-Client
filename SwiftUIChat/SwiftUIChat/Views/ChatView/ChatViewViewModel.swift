//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation
import Combine

class ChatViewViewModel: ObservableObject {
    @Published var viewData: [MessageViewData] = []
    @Published var status: ChatRoom.Status = .notConnected

    let loginManager: LoginManager

    private let user: User
    private let chatRoom: ChatProtocol
    private let messageHistory: HistoryProtocol

    private var subscribed = false
    
    private var subscriptions = Set<AnyCancellable>()

    init(user: User, chatRoom: ChatProtocol = ChatRoom(), messageHistory: HistoryProtocol = MessageHistory(), loginManager: LoginManager) {
        self.user = user
        self.chatRoom = chatRoom
        self.messageHistory = messageHistory
        self.loginManager = loginManager
    }

    func subscribe() {
        guard !subscribed else {
            return
        }
        subscribed = true
        let user = self.user

        messageHistory.history.sink { [weak self] history in
            self?.viewData = history.map { $0.viewData(given: user) }
        }.store(in: &subscriptions)

        chatRoom.status.sink { [weak self] status in
            self?.status = status
        }.store(in: &subscriptions)

        chatRoom.messageStatus.sink { [weak self] status in
            switch status {
            case .received(let message), .sent(let message):
                self?.messageHistory.add(message: message)
            }
        }.store(in: &subscriptions)

        chatRoom.joinChat(with: user)
    }

    func send(message body: String) {
        let uuid = UUID()
        let date = Date()
        let message = Message(uuid: uuid, date: date, user: user, body: body)
        chatRoom.send(message: message)
    }

    func logout() {
        loginManager.logout()
    }

    deinit {
        chatRoom.stopChatSession()
    }
}
