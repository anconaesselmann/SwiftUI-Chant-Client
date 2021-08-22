//  Created by Axel Ancona Esselmann on 8/22/21.
//

import Foundation

struct Token: Codable {
    let token: UUID
    let userId: UUID
    let expires: String
}
