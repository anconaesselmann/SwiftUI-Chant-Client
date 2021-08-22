//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var loginManager: LoginManager
    let networking: SocketNetworkingProtocol

    init(loginManager: LoginManager, networking: SocketNetworkingProtocol) {
        self.loginManager = loginManager
        self.networking = networking
    }
    
    @State var showSignup = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)
                Group {
                    switch loginManager.state {
                    case .loggedIn:
                        let vm = ChatViewViewModel(
                            networking: networking,
                            loginManager: loginManager
                        )
                        ChatView(viewModel: vm)
                    case .loggedOut:
                        Group {
                            if showSignup {
                                SignupView(
                                    showSignup: $showSignup,
                                    networking: networking,
                                    loginManager: loginManager
                                )
                            } else {
                                LoginView(
                                    showSignup: $showSignup,
                                    networking: Container.shared.networking,
                                    loginManager: loginManager
                                )
                            }
                        }
                        .frame(width: 250, alignment: .center)
                        .background(Color.background)
                        .cornerRadius(10)
                        .shadow(.background)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(loginManager: LoginManager(), networking: MockNetworking())
            .preferredColorScheme(.dark)
    }
}
