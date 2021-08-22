//  Created by Axel Ancona Esselmann on 8/18/21.
//

import Foundation

struct MessageViewData {
    let dateString: String?
    let type: MessageType
    let body: String
    var read: Bool

    static func dateString(for date: Date) -> String {
        let formater = DateFormatter()
        formater.dateFormat = "MMM d, h:mm a"
        return formater.string(from: date)
    }
}

extension Message {
    func viewData(given sender: UUID) -> MessageViewData {
        MessageViewData(dateString: MessageViewData.dateString(for: date), type: sender == self.sender ? .sent : .recieved, body: body, read: read)
    }
}
