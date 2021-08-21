//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

enum Padding {
    case left
    case right
}

func padd(_ string: String, with padingChar: String, lentgh: Int, padding: Padding = .left) -> String? {
    guard padingChar.count == 1, string.count < lentgh else {
        return nil
    }
    let paddingString = String(Array(repeating: padingChar, count: lentgh - string.count).joined())
    switch padding {
    case .left: return paddingString + string
    case .right: return string + paddingString
    }
}

protocol Request: Codable {
    var requestType: RequestType { get }
}

extension Request {

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    var encoded: Data? {
        guard
            let type = padd(String(self.requestType.rawValue), with: " ", lentgh: 2),
            let data = try? Self.encoder.encode(self),
            let serialized = String(data: data, encoding: .utf8),
            let header = padd(String(serialized.count), with: " ", lentgh: 10),
            let messageData = (type + header + serialized).data(using: .utf8)
        else {
            return nil
        }
        let messageString = type + header + serialized
        print(messageString)

        return messageData
    }
}

enum RequestType: Int {
    case newUser, emailLogin, tokenLogin, loggedIn, chatClient, chatServer, loggedOut
}

struct EmailLoginRequest: Request {
    let email: String
    let password: String
}


extension EmailLoginRequest {
    var requestType: RequestType {
        RequestType.emailLogin
    }
}


struct TokenLoginRequest: Request {
    let userId: String
    let token: String
}

extension TokenLoginRequest {
    var requestType: RequestType {
        RequestType.tokenLogin
    }
}


struct ChatMessageRequest: Request {
    let senderId: String
    let chatId: String
    let messageId: String
    let token: String
    let body: String
}

extension ChatMessageRequest {
    var requestType: RequestType {
        RequestType.chatClient
    }
}

struct ChatMessageResponse: Request {
    let chatId: String
    let messageId: String
    let senderName: String
    let body: String
    let date: String
}

extension ChatMessageResponse {
    var requestType: RequestType {
        RequestType.chatServer
    }
}

struct LogoutRequest: Request {
    let userId: String
    let token: String
}

extension LogoutRequest {
    var requestType: RequestType {
        RequestType.loggedOut
    }
}
