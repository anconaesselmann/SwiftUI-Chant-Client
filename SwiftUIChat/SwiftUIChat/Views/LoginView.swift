//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    @State var selection: Int?

    let loginManager: LoginManagerProtocol

    var body: some View {
        VStack {
            TextField("Username", text: $username)
            Button(action: {
                guard !username.isEmpty else {
                    return
                }
                let user = User(name: username)
                loginManager.logIn(user)
            }) {
                Text("Login")
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginManager: MockLoginManager())
            .frame(width: 300, height: 300)
            .previewLayout(.sizeThatFits)
    }
}
