//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

@main
struct SwiftUIChatApp: App {
    let container = Container.shared

    var body: some Scene {
        WindowGroup {
            ContentView(loginManager: container.loginManager, networking: container.networking)
        }
    }
}
