//  Created by Axel Ancona Esselmann on 8/18/21.
//

import SwiftUI

fileprivate extension CGFloat {
    static let messageOffset: CGFloat = 20
    static let smallCornerRadius: CGFloat = 16
    static let largeCornerRadius: CGFloat = 20
}

struct SentMessageView: View {

    let message: MessageViewData

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .trailing, spacing: 0) {
                DateHeaderView(dateString: message.dateString)
                MessageBodyView(messageBody: message.body)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .background(
                Color.sentMessageBackground
                    .cornerRadius(.largeCornerRadius)
                    .shadow(.background))
            .padding([.leading], .messageOffset)
        }
    }
}

struct RecievedMessageView: View {

    let message: MessageViewData

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                DateHeaderView(dateString: message.dateString)
                FromView(fromString: "From: \(message.userName)")
                MessageBodyView(messageBody: message.body)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(
                Color.receivedMessageBackground
                    .cornerRadius(.largeCornerRadius)
                    .shadow(.background))
            .padding([.trailing], .messageOffset)
        }
    }
}