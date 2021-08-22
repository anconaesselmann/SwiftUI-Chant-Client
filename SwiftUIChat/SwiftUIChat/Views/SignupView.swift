//  Created by Axel Ancona Esselmann on 8/20/21.
//

import SwiftUI

struct SignupView: View {
    @State var email: String = ""
    @State var username: String = ""
    @State var password: String = ""

    @Binding var showSignup: Bool

    let networking: SocketNetworkingProtocol
    let loginManager: LoginManager

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            TextField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
                    return
                }
                networking.newUser(email: email, name: username, password: password)
                showSignup = false
            }) {
                Text("Sign Up")
            }.padding([.bottom], .mediumPadding)
            Button(action: {
                self.showSignup = false
            }) {
                Text("Already have an account?")
            }.padding([.bottom], .mediumPadding)
        }.navigationBarTitle("Sign up", displayMode: .inline)
    }
}

struct SignupView_Previews: PreviewProvider {
    @State static var showSignup: Bool = false
    static var previews: some View {
        SignupView(showSignup: $showSignup, networking: MockNetworking(), loginManager: LoginManager())
    }
}
