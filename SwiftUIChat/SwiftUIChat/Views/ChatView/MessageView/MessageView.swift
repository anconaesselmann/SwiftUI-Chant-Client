//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct MessageView: View {

    let message: MessageViewData

    var body: some View {
        Group {
            switch message.type {
            case .sent:     SentMessageView(message:     message)
            case .recieved: RecievedMessageView(message: message)
            }
        }
        .padding(.smallPadding)
        .background(Color.background)
    }
}

struct MessageView_Previews: PreviewProvider {
    static let user = LoggedOutUser(name: "axel")
    static let sender = UUID()
    static let messageSent = Message(uuid: UUID(), date: Date(), sender: sender, body: "Hello World").viewData(given: sender)
    static let messageRecieved = Message(uuid: UUID(), date: Date(), sender: UUID(), body: "Hello World back").viewData(given: sender)
    
    static var previews: some View {
        Group {
            List {
                MessageView(message: messageSent)
                MessageView(message: messageRecieved)
            }
            .frame(width: 300, height: 230)
            .previewLayout(.sizeThatFits)
            List {
                MessageView(message: messageSent)
                MessageView(message: messageRecieved)
            }
            .frame(width: 300, height: 230)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
        }
    }
}
