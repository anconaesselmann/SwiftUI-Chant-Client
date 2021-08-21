//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

protocol Request: Codable {
    var requestType: ClientRequestType { get }
}

extension Request {

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }
    var encoded: Data? {
        guard
            let type = padd(String(self.requestType.rawValue), with: " ", lentgh: 2),
            let data = try? Self.encoder.encode(self),
            let serialized = String(data: data, encoding: .utf8),
            let header = padd(String(serialized.count), with: " ", lentgh: 10),
            let messageData = (type + header + serialized).data(using: .utf8)
        else {
            return nil
        }
        let messageString = type + header + serialized
        print(messageString)

        return messageData
    }
}
