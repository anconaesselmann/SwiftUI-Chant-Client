//  Created by Axel Ancona Esselmann on 8/16/21.
//

import Foundation

protocol User: Codable {
    var name: String { get }
}

struct LoggedOutUser: Hashable, User {
    let name: String
}
