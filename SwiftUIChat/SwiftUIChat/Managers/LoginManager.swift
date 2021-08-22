//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation
import SwiftUI

extension Notification.Name {
    static let loggedIn = Notification.Name(rawValue: "LoggedInNotification")
}

protocol LoginManagerProtocol: AnyObject {
    func logIn(_ token: Token)
    func logout()
    var token: Token? { get }
}

class LoginManager: ObservableObject, LoginManagerProtocol {

    enum State {
        case loggedIn(Token)
        case loggedOut

        var token: Token? {
            switch self {
            case .loggedIn(let token): return token
            case .loggedOut: return nil
            }
        }
    }

    @AppStorage("token") var tokenString: String?
    @AppStorage("expires") var expiresString: String?
    @AppStorage("userId") var userIdString: String?

    var token: Token? {
        guard let tokenString = tokenString, let tokenUuid = UUID(uuidString: tokenString), let expiresString = expiresString, let userIdString = userIdString, let userUuid = UUID(uuidString: userIdString) else {
            return nil
        }
        return Token(token: tokenUuid, userId: userUuid, expires: expiresString)
    }

    @Published var state: State = .loggedOut {
        didSet {
            switch state {
            case .loggedIn(let token):
                tokenString = token.token.uuidString
                expiresString = token.expires
                userIdString = token.userId.uuidString
            case .loggedOut:
                tokenString = nil
                expiresString = nil
                userIdString = nil
                if let token = state.token {
                    networking.logOut(token: token)
                }
            }
        }
    }

    let networking: SocketNetworkingProtocol

    init(networking: SocketNetworkingProtocol) {
        self.networking = networking
        NotificationCenter.default.addObserver(self, selector: #selector(loggedInNotification(notification:)), name: .loggedIn, object: nil)
        if let token = token {
            networking.logIn(token: token)
        }
    }

    @objc func loggedInNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let token = Token(dict: userInfo) else {
            return
        }
        logIn(token)
    }

    func logIn(_ token: Token) {
        state = .loggedIn(token)
    }

    func logout() {
        state = .loggedOut
    }
}

struct LoggedInUser: User {
    let name: String
    let token: Token
}
