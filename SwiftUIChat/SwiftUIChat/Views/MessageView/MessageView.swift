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
        .background(Color.clear)
    }
}

struct MessageView_Previews: PreviewProvider {
    static let user = User(name: "axel")
    static let messageSent = Message(uuid: UUID(), date: Date(), user: user, body: "Hello World").viewData(given: user)
    static let messageRecieved = Message(uuid: UUID(), date: Date(), user: User(name: "sam"), body: "Hello World back").viewData(given: user)
    
    static var previews: some View {
        Group {
            VStack {
                MessageView(message: messageSent)
                    .frame(width: 300, height: 104)
                MessageView(message: messageRecieved)
                    .frame(width: 300, height: 120)
            }
            .previewLayout(.sizeThatFits)
            VStack {
                MessageView(message: messageSent)
                    .frame(width: 300, height: 120)
                MessageView(message: messageRecieved)
                    .frame(width: 300, height: 120)
            }
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
        }
    }
}
