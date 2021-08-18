//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    @State var selection: Int?

    @State var user: User?
    var body: some View {
        VStack {
            TextField("Username", text: $username)
            NavigationLink(
                destination: NavigationLazyView(
                    Group {
                        if let user = user {
                            ChatView(viewModel: ChatViewViewModel(user: user))
                        } else {
                            Text("Not logged in")
                        }
                    }
                ),
                tag: 1,
                selection: $selection
            ) {
                Button(action: {
                    guard !username.isEmpty else {
                        return
                    }
                    self.user = User(name: username)
                    selection = 1
                }) {
                    Text("Login")
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
