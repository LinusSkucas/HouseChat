//
//  MainChatView.swift
//  HouseChat
//
//  Created by Linus Skucas on 12/3/20.
//

import SwiftUI

struct MainChatView: View {
    @State private var draftMessageText = ""
    @EnvironmentObject var connectionManager: ConnectionManager

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Divider()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(connectionManager.frens, id: \.self) { fren in
                            Text(fren.displayName)
                                .padding(.all, 5)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                }
                Divider()
            }
            .padding(.vertical, 10)
            .padding(.leading, 20)
            .frame(height: 30)
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(connectionManager.messages) { message in
                        HStack {
                            if message.isCurrentDevice {
                                Spacer()
                            }
                            VStack(spacing: 5) {
                                Text(message.message)
                                    .font(.body)
                                    .padding(4)
                                    .foregroundColor(.white)
                                    .background(message.isCurrentDevice ? Color(.orange) : Color(.purple))
                                    .cornerRadius(5)
                                Text(message.displayName)
                                    .font(.caption)
                                    .fontWeight(.thin)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            Spacer()
            TextField("Message!", text: $draftMessageText, onCommit: {
                guard !draftMessageText.isEmpty else { return }
                connectionManager.sendMessage(draftMessageText)
                draftMessageText = ""
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
        }
    }
}

struct MainChatView_Previews: PreviewProvider {
    static var previews: some View {
        MainChatView()
    }
}
