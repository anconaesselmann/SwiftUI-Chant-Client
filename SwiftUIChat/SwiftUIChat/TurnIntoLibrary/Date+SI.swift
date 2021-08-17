//  Created by Axel Ancona Esselmann on 8/16/21.
//

import Foundation

extension Date {
    static var siFormat: String {
        "yyyy-MM-dd HH:mm:ss"
    }
    var siString: String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = Self.siFormat
        return format.string(from: date)
    }

    init?(siString: String) {
        let format = DateFormatter()
        format.dateFormat = Self.siFormat
        if let date = format.date(from: siString) {
            self = date
        } else {
            return nil
        }
    }
}
