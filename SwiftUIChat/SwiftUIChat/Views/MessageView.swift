//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct MessageViewData {
    let dateString: String
    let userName: String
    let type: MessageType
    let body: String
}

extension Message {
    func viewData(given user: User) -> MessageViewData {
        MessageViewData(dateString: date.siString, userName: self.user.name, type: user.name == self.user.name ? .sent : .recieved, body: body)
    }
}

struct MessageView: View {
    let message: MessageViewData

    var body: some View {
        Group {
            switch message.type {
            case .sent:
                HStack {
                    Color.background.frame(width: 20)
                    VStack(alignment: .trailing, spacing: 0, content: {
                        Text(message.dateString).padding([.top, .leading, .trailing], 16.0)
                        Text(message.body).padding(16)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                    .background(Color(.green).cornerRadius(20))
                }
            case .recieved:
                HStack {
                    VStack(alignment: .leading, spacing: 0, content: {
                        Text(message.dateString).padding([.top, .leading, .trailing], 16.0)
                        Text("From: \(message.userName)").padding([.top, .leading, .trailing], 16.0)
                        Text(message.body).padding(.all, 16.0)
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .background(Color(.gray).cornerRadius(20))
                    Color.background.frame(width: 20)
                }
            }
        }.background(Color.background)
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
                    .frame(width: 300, height: 100)
                MessageView(message: messageRecieved)
                    .frame(width: 300, height: 100)
            }
            .previewLayout(.sizeThatFits)
            VStack {
                MessageView(message: messageSent)
                    .frame(width: 300, height: 100)
                MessageView(message: messageRecieved)
                    .frame(width: 300, height: 100)
            }
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
        }
    }
}
