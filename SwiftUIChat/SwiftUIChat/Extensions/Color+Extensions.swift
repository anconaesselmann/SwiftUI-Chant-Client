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


struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
