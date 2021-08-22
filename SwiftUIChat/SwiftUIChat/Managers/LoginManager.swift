//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation
import SwiftUI

protocol LoginManagerProtocol: ObservableObject {
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

    var token: Token? { state.token }

    @Published var state: State = .loggedOut {
        didSet { store(state: state) }
    }

    var networking: SocketNetworkingProtocol? {
        didSet {
            if networking != nil {
                restore()
            }
        }
    }

    private func restore() {
        guard let tokenString = tokenString, let tokenUuid = UUID(uuidString: tokenString), let expiresString = expiresString, let userIdString = userIdString, let userUuid = UUID(uuidString: userIdString) else {
            return
        }
        let token = Token(token: tokenUuid, userId: userUuid, expires: expiresString)
        networking?.logIn(token: token)
    }

    private func store(state: State) {
        switch state {
        case .loggedIn(let token):
            tokenString = token.token.uuidString
            expiresString = token.expires
            userIdString = token.userId.uuidString
        case .loggedOut:
            tokenString = nil
            expiresString = nil
            userIdString = nil
        }
    }

    func logIn(_ token: Token) {
        state = .loggedIn(token)
    }

    func logout() {
        if let token = state.token {
            networking?.logOut(token: token)
        }
        state = .loggedOut
    }
}
