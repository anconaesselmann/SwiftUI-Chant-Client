//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

enum ServerResponseType: Int {
    case loggedIn, chatMessage, typingStatusUpdate, messageReceived
}

protocol ServerResponse: Codable {
    static var serverResponseType: ServerResponseType { get }
}

struct ChatMessageResponse: ServerResponse {
    let chatId: UUID
    let messageId: UUID
    let senderName: String
    let body: String
    let date: String

    static var serverResponseType: ServerResponseType { .chatMessage }
}

struct TypingStatusUpdateResponse: ServerResponse {
    let chatId: UUID
    let isTyping: Bool
    let senderName: String

    static var serverResponseType: ServerResponseType { .typingStatusUpdate }
}

struct MessageReceivedServerNotification: ServerResponse {
    let messageId: UUID

    static var serverResponseType: ServerResponseType { .messageReceived }
}
