//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation
import Combine

class ChatViewViewModel: ObservableObject {
    @Published var viewData: [MessageViewData] = []
    @Published var status: SocketNetworking.Status = .notConnected

    let loginManager: LoginManager

    private let networking: SocketNetworkingProtocol
    private let messageHistory: HistoryProtocol

    private var subscribed = false
    
    private var subscriptions = Set<AnyCancellable>()

    init(networking: SocketNetworkingProtocol = SocketNetworking(), messageHistory: HistoryProtocol = MessageHistory(), loginManager: LoginManager) {
        self.networking = networking
        self.messageHistory = messageHistory
        self.loginManager = loginManager
    }

    func subscribe() {
        guard !subscribed else {
            return
        }
        subscribed = true

        messageHistory.history.sink { [weak self] history in
            guard let sender = self?.loginManager.userId else {
                return
            }
            self?.viewData = history.map { $0.viewData(given: UUID(uuidString: sender)!) }
        }.store(in: &subscriptions)

        networking.status.sink { [weak self] status in
            self?.status = status
        }.store(in: &subscriptions)

        networking.messageStatus.sink { [weak self] status in
            switch status {
            case .received(let message), .sent(let message):
                self?.messageHistory.add(message: message)
            }
        }.store(in: &subscriptions)

//        networking.joinChat(with: user)
    }

    func send(message body: String) {
        let uuid = UUID()
        let date = Date()
        guard let sender = loginManager.userId else {
            return
        }
//        let loggedOutUser = LoggedOutUser(name: user.name)
        let message = Message(uuid: uuid, date: date, sender: UUID(uuidString: sender)!, body: body)
        networking.send(message: message)
    }

    func logout() {
        loginManager.logout()
    }

    deinit {
        networking.stopChatSession()
    }
}
