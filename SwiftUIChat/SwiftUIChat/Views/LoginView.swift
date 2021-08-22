//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct LoginView: View {
    @State var email: String = ""
    @State var password: String = ""

    @Binding var showSignup: Bool

    let networking: SocketNetworkingProtocol
    let loginManager: LoginManager

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                guard !email.isEmpty, !password.isEmpty else {
                    return
                }
                networking.logIn(email: email, password: password)
            }) {
                Text("Login")
            }.padding([.bottom], .mediumPadding)
            Button(action: {
                self.showSignup = true
            }) {
                Text("Don't have an account?")
            }.padding([.bottom], .mediumPadding)
        }.navigationBarTitle("Login", displayMode: .inline)
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var showSignup: Bool = false
    static var previews: some View {
        LoginView(showSignup: $showSignup, networking: MockNetworking(), loginManager: LoginManager())
            .frame(width: 300, height: 500)
            .previewLayout(.sizeThatFits)
    }
}
