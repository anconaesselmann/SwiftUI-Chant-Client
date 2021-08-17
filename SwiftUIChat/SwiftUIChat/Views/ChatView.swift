//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct ChatView: View {

    @StateObject var chatRoom = ChatRoom()

    @State var message: String = ""

    let user: User

    var body: some View {
        Group {
            switch chatRoom.status {
            case .notConnected:
                Text("Not Connected")
            case .error:
                Text("Error")
            case .connected:
                ScrollViewReader { proxy in
                    VStack {
                        List() {
                            ForEach((0..<chatRoom.history.count).reversed(), id: \.self) { i in
                                let message = chatRoom.history[i]
                                MessageView(message: message.viewData(given: user))
                                    .flippedUpsideDown()
                            }
                        }.flippedUpsideDown()
                        TextField("Message", text: $message)
                            .padding()
                        Button(action: {
                            chatRoom.send(message: message)
                            message = ""
                        }, label: {
                            Text("Send")
                        }).padding()
                    }
                }
            }
        }.onAppear {
            chatRoom.joinChat(with: user)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static let user = User(name: "Axel")
    static var previews: some View {
        ChatView(user: user)
    }
}
