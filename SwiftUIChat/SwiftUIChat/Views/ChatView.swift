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
                VStack {
                    List() {
                        ForEach((0..<chatRoom.history.count).reversed(), id: \.self) { i in
                            let message = chatRoom.history[i]
                            MessageView(message: message.viewData(given: user))
                                .flippedUpsideDown()
                        }
                    }.background(color: .background)
                    .flippedUpsideDown()
                    TextField("Message", text: $message)
                        .padding()
                    Button(action: {
                        chatRoom.send(message: message)
                        message = ""
                    }, label: {
                        Text("Send")
                    })
                    .padding()
                }
            }
        }
        .background(Color.background)
        .navigationBarTitle("Chat", displayMode: .inline)
        .onAppear {
            chatRoom.joinChat(with: user)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static let user = User(name: "Axel")
    static var previews: some View {
        Group {
            ChatView(user: user)
                .frame(width: 400, height: 300)
                .previewLayout(.sizeThatFits)
            ChatView(user: user)
                .preferredColorScheme(.dark)
                .frame(width: 400, height: 300)
                .previewLayout(.sizeThatFits)
        }
    }
}
