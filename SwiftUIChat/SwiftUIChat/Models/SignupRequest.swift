//  Created by Axel Ancona Esselmann on 8/20/21.
//

import Foundation

struct SignupRequest: Request {
    let email: String
    let name: String
    let password: String
}

extension SignupRequest {
    var requestType: RequestType {
        RequestType.newUser
    }
}
