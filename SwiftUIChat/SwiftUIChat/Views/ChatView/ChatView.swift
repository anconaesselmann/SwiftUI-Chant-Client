//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewViewModel

    var body: some View {
        Group {
            switch viewModel.status {
            case .notConnected:
                Text("Not Connected")
            case .error:
                Text("Error")
            case .connected:
                VStack {
                    List() {
                        ForEach((0..<viewModel.viewData.count).reversed(), id: \.self) { i in
                            MessageView(message: viewModel.viewData[i])
                                .flippedUpsideDown()
                                .padding(.extraSmallPadding)
                        }
                    }
                    .background(color: .clear)
                    .background(Color.clear)
                    .flippedUpsideDown()
                    ChatComposeView() {
                        viewModel.send(message: $0)
                    }
                    .padding([.top, .bottom], .mediumPadding)
                    .background(
                        Color.background
                            .ignoresSafeArea(edges: .bottom)
                            .shadow(.background)
                    )
                }
            }
        }
        .navigationBarTitle("Chat", displayMode: .inline)
        .onAppear {
            viewModel.subscribe()
        }
    }
}


import Combine

struct ChatView_Previews: PreviewProvider {
    static let user = User(name: "Axel")
    static let vm = ChatViewViewModel(user: user, chatRoom: MockChat(), messageHistory: {
        let history = MockHistory()
        history.history = Just(
            [
                Message(uuid: UUID(), date: Date(), user: User(name: "Axel"), body: "Hello world"),
                Message(uuid: UUID(), date: Date(), user: User(name: "Sam"), body: "Mewo")
            ]
        ).eraseToAnyPublisher()
        return history
    }())
    static var previews: some View {
        Group {
            ChatView(viewModel: vm)
                .frame(width: 400, height: 300)
                .previewLayout(.sizeThatFits)
            ChatView(viewModel: vm)
                .preferredColorScheme(.dark)
                .frame(width: 400, height: 400)
                .previewLayout(.sizeThatFits)
        }
    }
}
