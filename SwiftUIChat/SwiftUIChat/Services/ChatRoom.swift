//  Created by Axel Ancona Esselmann on 8/16/21.
//

import Foundation
import Combine

class ChatRoom: ObservableObject, ChatRoomProtocol {

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

    @Published var status: ChatRoom.Status = .notConnected
    @Published var history: [Message] = []

    private var user: User?

    deinit {
        stopChatSession()
    }

    private let socket = Socket()

    private var subscriptions = Set<AnyCancellable>()

    private var connected = false

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
                switch status {
                case .notInitialized, .disconnected:
                    self?.status = .notConnected
                    self?.connected = false
                case .connected:
                    self?.status = .connected
                    self?.connected = true
                case .notConnectedWithError(let error):
                    self?.status = .error(.error(error))
                    self?.connected = false
                }
            }.store(in: &subscriptions)
    }

    func joinChat(with user: User) {
        if self.user == user && connected {
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

    func send(message body: String) {
        guard let user = user else {
            return
        }
        let uuid = UUID()
        let date = Date()
        let message = Message(uuid: uuid, date: date, user: user, body: body)
        guard let jsonString = message.jsonString else {
            status = .error(.couldNotSendMessage)
            return
        }
        let messageString = Self.header(for: jsonString) + jsonString
        guard let data = messageString.data(using: .utf8) else {
            return
        }
        self.socket.write(data: data)
        history.append(message)
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
            history.append(message)
        case .bytesWritten: ()
        case .error(let error):
            status = .error(.error(error))
        }
    }

    private func messageFromData(_ data: Data) -> Message? {
        guard let string = String(data: data, encoding: .utf8) else {
            status = .error(.couldNotReadMessage)
            return nil
        }
        let characters = Array(string)
        guard !characters.isEmpty else {
            status = .notConnected
            return nil
        }
        let userHeader = String(characters[..<10]).trimmingCharacters(in: .whitespaces)
        guard let userNameLenght = Int(userHeader) else {
            status = .error(.couldNotReadMessage)
            return nil
        }
        let messageHeaderStart = userNameLenght + 10
        let messageStart = messageHeaderStart + 10
        let jsonString = String(characters[messageStart...])
        return Message(jsonString: jsonString)
    }
}
