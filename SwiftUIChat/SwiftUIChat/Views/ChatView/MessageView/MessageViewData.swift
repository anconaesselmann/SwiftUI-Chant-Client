//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation

struct MessageViewData {
    let dateString: String
    let userName: String
    let type: MessageType
    let body: String

    static func dateString(for date: Date) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, h:mm a"
        return formater.string(from: date)
    }
}

extension Message {
    func viewData(given user: User) -> MessageViewData {
        MessageViewData(dateString: MessageViewData.dateString(for: date), userName: self.user.name, type: user.name == self.user.name ? .sent : .recieved, body: body)
    }
}
