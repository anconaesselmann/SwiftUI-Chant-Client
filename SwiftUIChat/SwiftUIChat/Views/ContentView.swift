//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationView(content: {
            LoginView()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
