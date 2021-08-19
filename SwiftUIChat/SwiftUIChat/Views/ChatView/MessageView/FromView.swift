//  Created by Axel Ancona Esselmann on 8/18/21.
//

import SwiftUI

struct FromView: View {
    let fromString: String
    var body: some View {
        Text(fromString).padding([.top, .bottom], 4.0)
            .foregroundColor(.white)
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .background(
                Color(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
                    .shadow(.background, y: 3)
            )
    }
}

struct FromView_Previews: PreviewProvider {
    static var previews: some View {
        FromView(fromString: "From: Axel")
            .frame(width: 300, height: 100)
            .previewLayout(.sizeThatFits)
    }
}
