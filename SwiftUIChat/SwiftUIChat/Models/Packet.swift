//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

enum Headers {
    case auth(Token)
}

struct Packet {

    enum PacketError: Error {
        case invalidData
        case noData
        case invalidTypeHeader
        case noHeader
        case invalidPayload
        case decodingError(ServerResponseType, Error)
    }

    let type: ServerResponseType
    let data: Data
    let headers: [Headers]

    init(type: ServerResponseType, data: Data, headers: [Headers] = []) {
        self.type = type
        self.data = data
        self.headers = headers
    }

    init(_ data: Data) throws {
        guard let string = String(data: data, encoding: .utf8) else {
            throw PacketError.invalidData
        }
        let characters = Array(string)
        guard !characters.isEmpty else {
            throw PacketError.noData
        }
        guard characters.count >= 2 else {
            throw PacketError.invalidTypeHeader
        }
        let typeHeader = String(characters[..<2]).trimmingCharacters(in: .whitespaces)
        guard
            let typeInt = Int(typeHeader),
            let type = ServerResponseType(rawValue: typeInt)
        else {
            throw PacketError.invalidTypeHeader
        }
        guard characters.count >= 12 else {
            throw PacketError.noHeader
        }
        let jsonString = String(characters[12...])

        guard let data = jsonString.data(using: .utf8) else {
            throw PacketError.invalidPayload
        }
        self.init(type: type, data: data)
    }

    func decode<T>() throws -> T where T: Decodable {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        print("Decoding ", String(data: data, encoding: .utf8) ?? "")
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw PacketError.decodingError(self.type, error)
        }
    }
}
