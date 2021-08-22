//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

enum ServerResponseType: Int {
    case loggedIn, chatMessage, typingStatusUpdate, messageReceived
}

struct ChatMessageResponse: Codable {
    let chatId: UUID
    let messageId: UUID
    let senderName: String
    let body: String
    let date: String
}

extension ChatMessageResponse {
    var requestType: ServerResponseType { .chatMessage }
}

struct TypingStatusUpdateResponse: Codable {
    let chatId: UUID
    let isTyping: Bool
    let senderName: String
}

extension TypingStatusUpdateResponse {
    var requestType: ServerResponseType {
        .typingStatusUpdate
    }
}

struct MessageReceivedServerNotification: Codable {
    let messageId: UUID
}

extension MessageReceivedServerNotification {
    var requestType: ServerResponseType { .messageReceived }
}
