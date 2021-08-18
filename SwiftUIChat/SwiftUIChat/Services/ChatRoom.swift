//  Created by Axel Ancona Esselmann on 8/16/21.
//

import Foundation
import Combine

protocol ChatProtocol {
    var status: AnyPublisher<ChatRoom.Status, Never> { get }
    var messageStatus: AnyPublisher<ChatRoom.MessageStatus, Never> { get }
    func joinChat(with user: User)
    func send(message: Message)
    func stopChatSession()
}

class ChatRoom: ChatProtocol {

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
    }

    private let messageStatusSubject = PassthroughSubject<MessageStatus, Never>()

    var messageStatus: AnyPublisher<MessageStatus, Never> {
        messageStatusSubject.eraseToAnyPublisher()
    }

    private let statusSubject = CurrentValueSubject<Status, Never>(.notConnected)

    var status: AnyPublisher<Status, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    private var user: User?

    deinit {
        stopChatSession()
    }

    private let socket = Socket()

    private var subscriptions = Set<AnyCancellable>()

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

    func joinChat(with user: User) {
        if self.user == user {
            return
        }
        self.user = user
        self.socket.open(url: Constants.socketUrlString, socket: Constants.socketPort)
        let message = Self.header(for: user.name) + user.name

        guard let data = message.data(using: .utf8) else {
            return
        }
        self.socket.write(data: data)
    }

    func send(message: Message) {
        guard let jsonString = message.jsonString else {
            statusSubject.send(.error(.couldNotSendMessage))
            return
        }
        let messageString = Self.header(for: jsonString) + jsonString
        guard let data = messageString.data(using: .utf8) else {
            return
        }
        self.socket.write(data: data) { [weak self] in
            self?.messageStatusSubject.send(.sent(message))
        }
    }

    func stopChatSession() {
        socket.close()
    }

    private static func header(for string: String) -> String {
        return String(Array("\(string.count)          ")[..<10])
    }

    private func eventReceived(_ event: Socket.Event) {
        switch event {
        case .data(let data):
            guard let message = messageFromData(data) else {
                return
            }
            messageStatusSubject.send(.received(message))
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

    private func messageFromData(_ data: Data) -> Message? {
        guard let string = String(data: data, encoding: .utf8) else {
            statusSubject.send(.error(.couldNotReadMessage))
            return nil
        }
        let characters = Array(string)
        guard !characters.isEmpty else {
            statusSubject.send(.notConnected)
            return nil
        }
        let userHeader = String(characters[..<10]).trimmingCharacters(in: .whitespaces)
        guard let userNameLenght = Int(userHeader) else {
            statusSubject.send(.error(.couldNotReadMessage))
            return nil
        }
        let messageHeaderStart = userNameLenght + 10
        let messageStart = messageHeaderStart + 10
        let jsonString = String(characters[messageStart...])
        return Message(jsonString: jsonString)
    }
}
