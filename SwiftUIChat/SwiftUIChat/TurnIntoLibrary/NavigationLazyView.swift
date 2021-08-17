//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct NavigationLazyView<Content: View>: View {

    private let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
