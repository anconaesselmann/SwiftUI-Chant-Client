//  Created by Axel Ancona Esselmann on 8/17/21.
//

import Foundation
import SwiftUI

extension UIColor {
    static var background: UIColor {
        UIColor(named: "Background")!
    }
}

extension Color {
    static var background: Color {
        Color(UIColor.background)
    }
}

extension List {
    // https://www.hackingwithswift.com/forums/swiftui/background-color-of-a-list-make-it-clear-color/3379
    func background(color: UIColor) -> some View {
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = color
        UITableView.appearance().backgroundColor = color
        return self
    }
}
