//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

enum ClientRequestType: Int {
    case signup, emailLogin, tokenLogin, chatMessage, loggedOut, typingStatusUpdate, messageRead
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
    let userId: String
    let token: String
}

extension TokenLoginRequest {
    var requestType: ClientRequestType { .tokenLogin }
}

struct ChatMessageRequest: Request {
    let senderId: String
    let chatId: String
    let messageId: String
    let token: String
    let body: String
}

extension ChatMessageRequest {
    var requestType: ClientRequestType { .chatMessage }
}

struct LogoutRequest: Request {
    let userId: String
    let token: String
}

extension LogoutRequest {
    var requestType: ClientRequestType { .loggedOut }
}

struct TypingStatusUpdateRequest: Request {
    let isTyping: Bool
    let userId: String
    let chatId: String
    let token: String
}

extension TypingStatusUpdateRequest {
    var requestType: ClientRequestType { .typingStatusUpdate }
}
