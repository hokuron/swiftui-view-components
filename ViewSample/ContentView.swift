//
//  ContentView.swift
//  ViewSample
//
//  Created by SHIMIZU Takuma on 2020/01/10.
//

import SwiftUI

private struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordFiledFocused = false

    @State private var isUsernameFieldCommitted = false

    var body: some View {
        VStack(spacing: 24) {
            UnderlineTextField("Username", text: $username, defaultColor: .systemGray4, highlightedColor: .systemBlue, onEditingChanged: {
                self.isPasswordFiledFocused = !(self.isUsernameFieldCommitted || $0)
                self.isUsernameFieldCommitted = !$0
            }, onCommit: {
                self.isUsernameFieldCommitted = true
            })
            UnderlineSecureField("Password", text: $password, isFocused: $isPasswordFiledFocused, defaultColor: .systemGray4, highlightedColor: .systemBlue)
        }
    }
}

struct ContentView: View {
    private let components = [
        "UnderLineTextField": LoginView.init
    ]

    var body: some View {
        NavigationView {
            List(components.keys.sorted(), id: \.self) { key in
                NavigationLink(key, destination: self.components[key]!())
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Components", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
