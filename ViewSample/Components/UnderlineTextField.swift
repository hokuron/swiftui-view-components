//
//  UnderlineTextField.swift
//  ViewSample
//
//  Created by SHIMIZU Takuma on 2020/01/10.
//

import SwiftUI

private struct FocusedLine: View {

    let lineWidth: CGFloat = 1.0
    let isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color(.systemGray3))
                .frame(height: lineWidth)
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: lineWidth)
                .frame(maxWidth: isFocused ? .infinity : 0)
        }
    }
}

struct UnderlineTextField: View {

    var title: String
    var lineWidth: CGFloat = 1.0

    @Binding var text: String
    @Binding var isFocused: Bool

    var onEditingChanged: (Bool) -> Bool = {_ in false}
    var onCommit: () -> Void = {}

    var body: some View {
        VStack {
            TextField(self.title, text: self.$text, onEditingChanged: {
                self.isFocused = self.onEditingChanged($0) || $0
            }, onCommit: onCommit)

            FocusedLine(isFocused: isFocused)
                .animation(isFocused ? .easeIn : .easeOut)
        }
    }
}

struct UnderlineSecureField: View {

    var title: String
    var lineWidth: CGFloat = 1.0

    @Binding var text: String
    @Binding var isFocused: Bool

    var onCommit: () -> Bool = {false}

    var body: some View {
        VStack {
            SecureField(title, text: $text, onCommit: {
                self.isFocused = self.onCommit()
            })
            .onTapGesture {
                self.isFocused = true
            }

            FocusedLine(isFocused: isFocused)
                .animation(isFocused ? .easeIn : .easeOut)
        }
    }
}

struct FocusedTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UnderlineTextField(title: "Email", text: .constant(""), isFocused: .constant(true))
            UnderlineSecureField(title: "Password", text: .constant(""), isFocused: .constant(false))
        }
        .padding()
    }
}
