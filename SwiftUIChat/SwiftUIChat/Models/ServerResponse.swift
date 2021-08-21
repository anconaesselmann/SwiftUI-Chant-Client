//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

enum ServerResponseType: Int {
    case loggedIn, chatMessage, typingStatusUpdate
}

struct ChatMessageResponse: Codable {
    let chatId: String
    let messageId: String
    let senderName: String
    let body: String
    let date: String
}

extension ChatMessageResponse {
    var requestType: ServerResponseType {
        .chatMessage
    }
}

struct TypingStatusUpdateResponse: Codable {
    let chatId: String
    let isTyping: Bool
    let senderName: String
}

extension TypingStatusUpdateResponse {
    var requestType: ServerResponseType {
        .typingStatusUpdate
    }
}
