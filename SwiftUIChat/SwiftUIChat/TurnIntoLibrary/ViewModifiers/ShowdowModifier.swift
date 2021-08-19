//  Created by Axel Ancona Esselmann on 8/18/21.
//

import SwiftUI

struct ShowdowModifier: ViewModifier {

    struct Shadow {
        let color: Color, radius: CGFloat, x: CGFloat, y: CGFloat
    }

    let shadow: Shadow

    init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        shadow = Shadow(color: color, radius: radius, x: x, y: y)
    }

    init(_ shadow: Shadow, x: CGFloat? = nil, y: CGFloat? = nil) {
        self.init(color: shadow.color, radius: shadow.radius, x: x ?? shadow.x, y: y ?? shadow.y)
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    func shadow(_ shadow: Shadows, x: CGFloat? = nil, y: CGFloat? = nil) -> some View {
        self.modifier(ShowdowModifier(shadow.shadow, x: x, y: y))
    }
}
