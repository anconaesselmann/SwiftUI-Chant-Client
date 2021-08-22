//  Created by Axel Ancona Esselmann on 8/16/21.
//

import Foundation
import Combine

protocol SocketNetworkingProtocol: AnyObject {
    var status: AnyPublisher<SocketNetworking.Status, Never> { get }
    var messageStatus: AnyPublisher<SocketNetworking.MessageStatus, Never> { get }
    func send(message: Message)
    func stopChatSession()

    func newUser(email: String, name: String, password: String)
    func logIn(email: String, password: String)
    func logIn(token: Token)
    func logOut(token: Token)
    func updateIsTyping(_ isTyping: Bool)
}

class SocketNetworking: SocketNetworkingProtocol {

    enum Status {
        case notConnected
        case error(ConnectionError)
        case connected
    }

    enum ConnectionError: Error {
        case couldNotJoinChat
        case couldNotSendMessage
        case couldNotReadMessage
        case disconnected
        case error(Error)
    }

    enum MessageStatus {
        case received(Message)
        case sent(Message)
        case isTyping(Bool)
        case messageRead(UUID)
    }

    private let messageStatusSubject = PassthroughSubject<MessageStatus, Never>()

    var messageStatus: AnyPublisher<MessageStatus, Never> {
        messageStatusSubject.eraseToAnyPublisher()
    }

    private let statusSubject = CurrentValueSubject<Status, Never>(.notConnected)

    var status: AnyPublisher<Status, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    deinit {
        print("Deinitializing")
        stopChatSession()
    }

    private let socket = Socket()

    private var subscriptions = Set<AnyCancellable>()

    let queue = DispatchQueue(label: "queue")

    init() {
        socket.event
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.eventReceived(event)
            }.store(in: &subscriptions)

        socket.status
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.statusChanged(status)
            }.store(in: &subscriptions)
    }

    func newUser(email: String, name: String, password: String) {
        self.socket.open(url: Constants.socketUrlString, socket: Constants.socketPort)

        let request = SignupRequest(email: email, name: name, password: password)
        guard let encoded = request.encoded else {
            return
        }
        socket.write(data: encoded)
    }

    func logIn(email: String, password: String) {
        self.socket.open(url: Constants.socketUrlString, socket: Constants.socketPort)

        let request = EmailLoginRequest(email: email, password: password)
        guard let encoded = request.encoded else {
            return
        }
        socket.write(data: encoded)
    }

    func logIn(token: Token) {
        self.socket.open(url: Constants.socketUrlString, socket: Constants.socketPort)

        let request = TokenLoginRequest(userId: token.userId, token: token.token)
        guard let encoded = request.encoded else {
            return
        }
        socket.write(data: encoded)
    }

    func logOut(token: Token) {
        let request = LogoutRequest(userId: token.userId, token: token.token)
        guard let encoded = request.encoded else {
            return
        }
        socket.write(data: encoded)
    }

    func send(message: Message) {
        guard let token = self.token else {
            return
        }
        let request = ChatMessageRequest(senderId: message.sender, chatId: UUID(), messageId: message.uuid, token: token.token, body: message.body)
        guard let encoded = request.encoded else {
            return
        }
        print("Message sent: ", String(data: encoded, encoding: .utf8) ?? "")
        socket.write(data: encoded) { [weak self] in
            self?.messageStatusSubject.send(.sent(message))
        }
    }

    private func sendReceivedReceipt(for message: Message) {
        guard let token = self.token else {
            return
        }
        let request = MessageReceivedClientNotification(messageId: message.uuid)
        guard let encoded = request.encoded else {
            return
        }
        print("Sending received receipt")
        socket.write(data: encoded)
    }

    func updateIsTyping(_ isTyping: Bool) {
        guard let token = token else {
            return
        }
        // TODO: ChatID is not real
        let request = TypingStatusUpdateRequest(isTyping: isTyping, userId: token.userId, chatId: UUID(), token: token.token)
        guard let encoded = request.encoded else {
            return
        }
        socket.write(data: encoded)
    }

    func stopChatSession() {
        socket.close()
    }

    private static func header(for string: String) -> String {
        return String(Array("\(string.count)          ")[..<10])
    }

    var token: Token?

    private func eventReceived(_ event: Socket.Event) {
        print("Event recieved: ", event)
        switch event {
        case .data(let data):
            do {
                let packet = try Packet(data)
                switch packet.type {
                case .loggedIn:
                    if let token: Token = packet.decode() {
                        print(token)
                        self.token = token
                        NotificationCenter.default.post(name: .loggedIn, object: nil, userInfo: token.dict)
                    } else {
                        print("Invalid token")
                    }
                case .chatMessage:
                    if let decoded: ChatMessageResponse = packet.decode() {
                        let message = Message(
                            uuid: decoded.messageId,
                            date: Date(),
                            sender: UUID(),
                            body: decoded.body)
                        messageStatusSubject.send(.received(message))
                        sendReceivedReceipt(for: message)
                    } else {
                        print("Could not read chat message")
                    }
                case .typingStatusUpdate:
                    if let statusUpdate: TypingStatusUpdateResponse = packet.decode() {
                        print("Status update: ", statusUpdate)
                        messageStatusSubject.send(.isTyping(statusUpdate.isTyping))
                    } else {
                        print("Could not read status update")
                    }
                case .messageReceived:
                    if let receipt: MessageReceivedServerNotification = packet.decode() {
                        print("Message read: ", receipt.messageId)
                        messageStatusSubject.send(.messageRead(receipt.messageId))
                    }
                }
            } catch {
                statusSubject.send(.error(ConnectionError.disconnected))
                print("Could not extract packet + \(error.localizedDescription)")
            }
        case .bytesWritten: ()
        case .error(let error):
            statusSubject.send(.error(.error(error)))
        }
    }

    private func statusChanged(_ newStatus: Socket.Status) {
        switch newStatus {
        case .connected:
            self.statusSubject.send(.connected)
        case .notInitialized, .disconnected:
            self.statusSubject.send(.notConnected)
        case .notConnectedWithError(let error):
            self.statusSubject.send(.error(.error(error)))
        }
    }

}

struct Token: Codable {
    let token: UUID
    let userId: UUID
    let expires: String

    init(token: UUID, userId: UUID, expires: String) {
        self.token = token
        self.userId = userId
        self.expires = expires
    }

    init?(dict: [AnyHashable: Any]) {
        guard let encoded = try? JSONSerialization.data(withJSONObject: dict, options: []) else { return nil }
        let decoder = JSONDecoder()
        if let token = try? decoder.decode(Self.self, from: encoded) {
            self = token
        } else {
            return nil
        }
    }

    var dict: [String: Any]? {
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(self) else { return nil }
        return try? JSONSerialization.jsonObject(with: encoded, options: []) as? [String:Any]
    }
}
