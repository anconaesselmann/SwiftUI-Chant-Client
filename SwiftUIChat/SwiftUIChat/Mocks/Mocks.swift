//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Combine
import Foundation

class MockNetworking: SocketNetworkingProtocol {
    var status: AnyPublisher<SocketNetworking.Status, Never> = Just(.connected).eraseToAnyPublisher()
    var messageStatus = PassthroughSubject<SocketNetworking.MessageStatus, Never>().eraseToAnyPublisher()
    func joinChat(with user: User) { }
    func send(message: Message) { }
    func stopChatSession() { }
    func logIn(email: String, password: String) { }
    func logIn(token: Token) { }
    func newUser(email: String, name: String, password: String) { }
    func logOut(token: Token) { }
    func updateIsTyping(_ isTyping: Bool) { }
}

class MockHistory: HistoryProtocol {
    var history: AnyPublisher<[Message], Never> = Just([]).eraseToAnyPublisher()
    func add(message: Message) { }
    func messageRead(id: UUID) { }
}

class MockLoginManager: LoginManagerProtocol {
    var userId: String?
    func logIn(_ token: Token) { }
    func logout() { }
}
