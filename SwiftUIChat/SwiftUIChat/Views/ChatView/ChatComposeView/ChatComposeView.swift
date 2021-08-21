//  Created by Axel Ancona Esselmann on 8/18/21.
//

import SwiftUI

struct ChatComposeView: View {
    @State var message: String = ""

    let onSend: (String) -> Void

    var body: some View {
        HStack {
            TextField("Message", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading], .mediumPadding)
            Button(action: {
                onSend(message)
                message = ""
                hideKeyboard() 
            }, label: {
                Text("Send")
            })
            .padding([.leading, .trailing], .mediumPadding)
        }
    }
}

struct ChatComposeView_Previews: PreviewProvider {

    static var previews: some View {
        ChatComposeView() { _ in

        }
        .frame(width: 400, height: 200)
        .previewLayout(.sizeThatFits)
    }
}
