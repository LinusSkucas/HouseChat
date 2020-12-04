//
//  ContentView.swift
//  HouseChat
//
//  Created by Linus Skucas on 12/3/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var connectionManager = ConnectionManager()
    
    var body: some View {
        NavigationView {
            HStack {
                Button(action: {
                    connectionManager.hostChat()
                }, label: {
                    Text("Host Chat!")
                        .padding()
                })
                Spacer()
                Button(action: {
                    connectionManager.joinChat()
                }, label: {
                    Text("Join a Chat!")
                        .padding()
                })
                NavigationLink(destination: MainChatView().environmentObject(connectionManager), isActive: $connectionManager.connected) {
                    EmptyView()
                }
            }
            .navigationBarTitle("House Chat")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
