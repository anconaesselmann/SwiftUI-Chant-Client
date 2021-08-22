//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

enum ClientRequestType: Int {
    case signup, emailLogin, tokenLogin, chatMessage, loggedOut, typingStatusUpdate, messageReceived
}

struct SignupRequest: Request {
    let email: String
    let name: String
    let password: String
}

extension SignupRequest {
    var requestType: ClientRequestType { .signup }
}

struct EmailLoginRequest: Request {
    let email: String
    let password: String
}


extension EmailLoginRequest {
    var requestType: ClientRequestType { .emailLogin }
}

struct TokenLoginRequest: Request {
    let userId: UUID
    let token: UUID
}

extension TokenLoginRequest {
    var requestType: ClientRequestType { .tokenLogin }
}

struct ChatMessageRequest: Request {
    let senderId: UUID
    let chatId: UUID
    let messageId: UUID
    let token: UUID
    let body: String
}

extension ChatMessageRequest {
    var requestType: ClientRequestType { .chatMessage }
}

struct LogoutRequest: Request {
    let userId: UUID
    let token: UUID
}

extension LogoutRequest {
    var requestType: ClientRequestType { .loggedOut }
}

struct TypingStatusUpdateRequest: Request {
    let isTyping: Bool
    let userId: UUID
    let chatId: UUID
    let token: UUID
}

extension TypingStatusUpdateRequest {
    var requestType: ClientRequestType { .typingStatusUpdate }
}

struct MessageReceivedClientNotification: Request {
    let messageId: UUID
}

extension MessageReceivedClientNotification {
    var requestType: ClientRequestType { .messageReceived }
}
