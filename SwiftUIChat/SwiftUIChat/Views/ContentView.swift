//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

class Container {
    var networking: SocketNetworking = SocketNetworking()
    lazy var loginManager = LoginManager(networking: networking)

    static let shared = Container()
}

struct ContentView: View {

    @StateObject var loginManager = Container.shared.loginManager
    @State var showSignup = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.background.edgesIgnoringSafeArea(.all)
                Group {
                    switch loginManager.state {
                    case .loggedIn:
                        let vm = ChatViewViewModel(
                            networking: Container.shared.networking,
                            loginManager: loginManager
                        )
                        ChatView(viewModel: vm)
                    case .loggedOut:
                        Group {
                            if showSignup {
                                SignupView(
                                    showSignup: $showSignup,
                                    networking: Container.shared.networking,
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
        ContentView()
            .preferredColorScheme(.dark)
    }
}
