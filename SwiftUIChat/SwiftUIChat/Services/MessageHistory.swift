//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation
import Combine

protocol HistoryProtocol {
    var history: AnyPublisher<[Message], Never> { get }
    func add(message: Message)
}
class MessageHistory: HistoryProtocol {

    private let historySubject = CurrentValueSubject<[Message], Never>([])

    var history: AnyPublisher<[Message], Never> {
        historySubject.eraseToAnyPublisher()
    }

    func add(message: Message) {
        var value = historySubject.value
        value.append(message)
        historySubject.send(value)
    }
}
