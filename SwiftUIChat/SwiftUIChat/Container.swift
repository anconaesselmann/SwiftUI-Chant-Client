//  Created by Axel Ancona Esselmann on 8/22/21.
//

import Foundation

class Container {
    var networking: SocketNetworkingProtocol

    var loginManager: LoginManager

    static let shared = Container()

    private init() {
        let loginManager = LoginManager()
        let networking = SocketNetworking(loginManager: loginManager)
        loginManager.networking = networking

        self.networking = networking
        self.loginManager = loginManager
    }
}
