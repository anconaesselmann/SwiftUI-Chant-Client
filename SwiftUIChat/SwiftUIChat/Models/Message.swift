//  Created by Axel Ancona Esselmann on 8/16/21.
//

import Foundation

enum MessageType: Int, Codable {
    case sent
    case recieved
}

struct Message: Hashable, Codable {
    let uuid: UUID
    let date: Date
    let sender: UUID
    let body: String

    func type(for uuid: UUID) -> MessageType {
        uuid.uuidString == self.sender.uuidString ? .sent : .recieved
    }
}

extension Message {
    var jsonString: String? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    init?(jsonString: String) {
        if let data = jsonString.data(using: .utf8), let message = try? JSONDecoder().decode(Self.self, from: data) {
            self = message
        } else {
            return nil
        }
    }
}
