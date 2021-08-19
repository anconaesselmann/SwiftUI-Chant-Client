//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation
import SwiftUI

protocol LoginManagerProtocol {
    func logIn(_ user: User)
    func logout()
}

class LoginManager: ObservableObject, LoginManagerProtocol {

    enum State {
        case loggedIn(User)
        case loggedOut
    }

    @AppStorage("username") var username: String?

    @Published var state: State = .loggedOut {
        didSet {
            switch state {
            case .loggedIn(let user):
                username = user.name
            case .loggedOut:
                username = nil
            }
        }
    }

    init() {
        if let username = self.username {
            state = .loggedIn(User(name: username))
        }
    }

    func logIn(_ user: User) {
        state = .loggedIn(user)
    }

    func logout() {
        username = nil
        state = .loggedOut
    }
}
