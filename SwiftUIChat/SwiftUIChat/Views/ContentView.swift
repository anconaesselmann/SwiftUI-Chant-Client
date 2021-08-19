//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct ContentView: View {

    @StateObject var loginManager = LoginManager()

    var body: some View {
        NavigationView {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)
                Group {
                    switch loginManager.state {
                    case .loggedIn(let user):
                        let vm = ChatViewViewModel(user: user, loginManager: loginManager)
                        ChatView(viewModel: vm)
                    case .loggedOut:
                        LoginView(loginManager: loginManager)
                    }
                }
            }.navigationBarTitle("Login", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
