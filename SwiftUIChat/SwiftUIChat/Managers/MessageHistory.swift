//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation
import Combine

protocol HistoryProtocol {
    var history: AnyPublisher<[Message], Never> { get }
    func add(message: Message)
    func messageRead(id: UUID)
}
class MessageHistory: HistoryProtocol {

    private let historySubject = CurrentValueSubject<[Message], Never>([])

    var history: AnyPublisher<[Message], Never> {
        historySubject.eraseToAnyPublisher()
    }

    func add(message: Message) {
        print("Adding message with id: ", message.uuid)
        var value = historySubject.value
        value.append(message)
        historySubject.send(value)
        print(value)
    }

    func messageRead(id: UUID) {
        var messages = historySubject.value
        print("Should update: ", id)
        print("Messages: ", messages)
        for i in 0..<messages.count {
            var message = messages[i]
            if message.uuid.uuidString.lowercased() == id.uuidString.lowercased() {
                message.read = true
                messages[i] = message
                print("read status updated")
            }
        }
        historySubject.send(messages)
    }
}
