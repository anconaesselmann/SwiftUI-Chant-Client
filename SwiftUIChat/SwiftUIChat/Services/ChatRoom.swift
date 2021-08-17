//  Created by Axel Ancona Esselmann on 8/16/21.
//

import Foundation
import Combine

class ChatRoom: ObservableObject {

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
        print("Closing sockets")
        stopChatSession()
    }

    let socket = Socket()

    var subscription: AnyCancellable?

    var connected = false

    init() {
        subscription = socket.event
            .sink { [weak self] event in
                guard let strongSelf = self else {
                    return
                }
                switch event {
                case .openCompleted:
                    print("openCompleted")
                case .data(let data):
                    print("Data recieved: \(String(data: data, encoding: .utf8) ?? "")")
                    guard let message = strongSelf.messageFromData(data) else {
                        return
                    }
                    strongSelf.history.append(message)
                case .bytesWritten(let bytesWritten):
                    print("Bytes written: \(bytesWritten)")
                case .hasSpaceAvailable:
                    print("hasSpaceAvailable")
                case .error(let error):
                    print(error)
                    strongSelf.connected = false
                case .endEncountered:
                    print("endEncountered")
                case .other(let eventCode):
                    if eventCode.rawValue == 1 {
                        print("Connected")
                        strongSelf.status = .connected
                        strongSelf.connected = true
                    } else {
                        print("other event: \(eventCode)")
                    }
                }
            }
    }

    func header(for string: String) -> String {
        return String(Array("\(string.count)          ")[..<10])
    }

    func joinChat(with user: User) {
        if self.user == user && connected {
            return
        }
        self.user = user
        socket.open(url: Constants.socketUrlString, socket: Constants.socketPort)
        let message = header(for: user.name) + user.name

        guard let data = message.data(using: .utf8) else {
            return
        }
        socket.write(data: data)
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
        let messageString = header(for: jsonString) + jsonString
        guard let data = messageString.data(using: .utf8) else {
            return
        }
        socket.write(data: data)
        history.append(message)
    }

    func stopChatSession() {
        socket.close()
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
