//  Created by Axel Ancona Esselmann on 8/18/21.
//

import SwiftUI

struct DateHeaderView: View {
    let dateString: String
    var body: some View {
        Text(dateString).padding([.top, .bottom], 4.0)
            .foregroundColor(.white)
            .font(.footnote)
            .frame(maxWidth: .infinity)
            .background(
                Color(UIColor.darkGray)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .shadow(.background, y: 3)
            )
    }
}

struct DateHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        DateHeaderView(dateString: "Date string")
            .frame(width: 300, height: 100)
            .previewLayout(.sizeThatFits)
    }
}
