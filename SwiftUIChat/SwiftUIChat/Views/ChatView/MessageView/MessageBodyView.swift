//  Created by Axel Ancona Esselmann on 8/18/21.
//

import SwiftUI

struct MessageBodyView: View {
    let messageBody: String
    var body: some View {
        Text(messageBody)
            .padding(.mediumPadding)
            .foregroundColor(.textOnBackground)
    }
}

struct MessageBodyView_Previews: PreviewProvider {
    static var previews: some View {
        MessageBodyView(messageBody: "Hello World")
            .frame(width: 300, height: 120)
            .previewLayout(.sizeThatFits)
    }
}
