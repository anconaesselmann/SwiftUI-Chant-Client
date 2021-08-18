//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Combine

class MockChat: ChatProtocol {
    var status: AnyPublisher<ChatRoom.Status, Never> = Just(.connected).eraseToAnyPublisher()

    var messageStatus = PassthroughSubject<ChatRoom.MessageStatus, Never>().eraseToAnyPublisher()

    func joinChat(with user: User) { }
    func send(message: Message) { }
    func stopChatSession() { }
}


class MockHistory: HistoryProtocol {
    var history: AnyPublisher<[Message], Never> = Just([]).eraseToAnyPublisher()

    func add(message: Message) { }
}
