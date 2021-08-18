//  Created by Axel Ancona Esselmann on 8/17/21.
//

import SwiftUI

struct FlippedUpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(180))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
extension View{
    func flippedUpsideDown() -> some View {
        self.modifier(FlippedUpsideDown())
    }
}



struct ShowdowModifier: ViewModifier {

    struct Shadow {
        let color: Color, radius: CGFloat, x: CGFloat, y: CGFloat
    }

    let shadow: Shadow

    init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.init(Shadow(color: color, radius: radius, x: x, y: y))
    }

    init(_ shadow: Shadow) {
        self.shadow = shadow
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    func shadow(_ shadow: Shadows) -> some View {
        self.modifier(ShowdowModifier(shadow.shadow))
    }
}


enum Shadows {
    case background

    var shadow: ShowdowModifier.Shadow {
        switch self {
        case .background: return ShowdowModifier.Shadow(color: Color.backgroundShaddow, radius: 6, x: 0, y: 0)
        }
    }
}
