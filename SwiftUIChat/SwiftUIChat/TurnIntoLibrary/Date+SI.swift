//  Created by Axel Ancona Esselmann on 8/16/21.
//

import Foundation

extension Date {
    static var siFormat: String {
        "yyyy-MM-dd HH:mm:ss"
    }

    static var siDateFormatter: DateFormatter = {
        let formater = DateFormatter()
        formater.dateFormat = Self.siFormat
        return formater
    }()

    var siString: String {
        Self.siDateFormatter.string(from: self)
    }

    init?(siString: String) {
        if let date = Self.siDateFormatter.date(from: siString) {
            self = date
        } else {
            return nil
        }
    }
}
