//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct ContentView: View {

    @StateObject var loginManager = LoginManager()

    var body: some View {
        NavigationView(content: {
            Group {
                switch loginManager.state {
                case .loggedIn(let user):
                    ChatView(viewModel: ChatViewViewModel(user: user, loginManager: loginManager))
                case .loggedOut:
                    LoginView(loginManager: loginManager)
                }
            }
        }).background(Color.background)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
