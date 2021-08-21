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
    var userId: String? { get }
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

    @AppStorage("token") var token: String?
    @AppStorage("expires") var expires: String?
    @AppStorage("userId") var userId: String?

    @Published var state: State = .loggedOut {
        didSet {
            switch state {
            case .loggedIn(let token):
                self.token = token.token
                expires = token.expires
                userId = token.userId
            case .loggedOut:
                token = nil
                expires = nil
                userId = nil
            }
        }
    }

    let networking: SocketNetworkingProtocol

    init(networking: SocketNetworkingProtocol) {
        self.networking = networking
        NotificationCenter.default.addObserver(self, selector: #selector(loggedInNotification(notification:)), name: .loggedIn, object: nil)
        if let token = token, let expires = expires, let userId = userId {
            let token = Token(token: token, userId: userId, expires: expires)
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
        if let token = state.token {
            networking.logOut(token: token)
        }
        token = nil
        expires = nil
        userId = nil
        state = .loggedOut
    }
}

struct LoggedInUser: User {
    let name: String
    let token: Token
}
