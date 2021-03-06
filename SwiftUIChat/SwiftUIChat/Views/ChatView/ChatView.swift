//  Created by Axel Ancona Esselmann on 8/16/21.
//

import SwiftUI

private extension CGFloat {
    static let listRowOffset: CGFloat = 0
}

struct ChatView: View {
    @StateObject var viewModel: ChatViewViewModel

    var body: some View {
        Group {
            switch viewModel.status {
            case .notConnected:
                ProgressView()
            case .error(let error):
                Text("Error: \(error.localizedDescription)")
                    .padding(.mediumPadding)
            case .connected:
                VStack(spacing: 0) {
                    List() {
                        Group {
                            if viewModel.chatPartnerIsTyping {
                                Section() {
                                    MessageView(message: MessageViewData(dateString: nil, type: .recieved, body: "...", read: false))
                                        .flippedUpsideDown()
                                        .listRowInsets(.init(top: .listRowOffset, leading: .listRowOffset, bottom: .listRowOffset, trailing: .listRowOffset))
                                }
                            }
                        }
                        Section() {
                            ForEach((0..<viewModel.viewData.count).reversed(), id: \.self) { i in
                                MessageView(message: viewModel.viewData[i])
                                    .flippedUpsideDown()
                                    .listRowInsets(.init(top: .listRowOffset, leading: .listRowOffset, bottom: .listRowOffset, trailing: .listRowOffset))
                            }
                        }

                    }
                    .background(color: .background)
                    .listStyle(PlainListStyle())
                    .background(Color.background)
                    .flippedUpsideDown()
                    ChatComposeView(message: $viewModel.message) {
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
        .toolbar {
            Button("Logout") {
                viewModel.logout()
            }
        }
        .onAppear {
            viewModel.subscribe()
        }
    }
}

import Combine

struct ChatView_Previews: PreviewProvider {
    static let loginManager = LoginManager()
    static let sender = UUID()
    static let vm = ChatViewViewModel(networking: MockNetworking(), messageHistory: {
        let history = MockHistory()
        history.history = Just(
            [
                Message(uuid: UUID(), date: Date(), sender: sender, body: "Hello world"),
                Message(uuid: UUID(), date: Date(), sender: UUID(), body: "Mewo")
            ]
        ).eraseToAnyPublisher()
        return history
    }(), loginManager: loginManager)
    static var previews: some View {
        Group {
            ChatView(viewModel: vm)
                .frame(width: 400, height: 300)
                .previewLayout(.sizeThatFits)
            ChatView(viewModel: vm)
                .preferredColorScheme(.dark)
                .frame(width: 400, height: 300)
                .previewLayout(.sizeThatFits)
        }
    }
}
