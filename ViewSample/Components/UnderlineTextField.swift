//
//  UnderlineTextField.swift
//  ViewSample
//
//  Created by SHIMIZU Takuma on 2020/01/10.
//

import SwiftUI

private struct FocusedLine: View {
    let lineWidth: CGFloat = 1.0
    let defaultLineColor: UIColor
    let highlightedLineColor: UIColor

    @Binding var isFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Divider()
                    .frame(height: self.lineWidth)
                    .background(Color(self.defaultLineColor))
                Divider()
                    .frame(width: geometry.size.width / 2.0, height: self.lineWidth)
                    .background(Color(self.highlightedLineColor))
                    .offset(x: self.isFocused ? 0 : -geometry.size.width, y: 0)
                Divider()
                    .frame(width: geometry.size.width / 2.0, height: self.lineWidth)
                    .alignmentGuide(.leading) { -$0.width }
                    .background(Color(self.highlightedLineColor))
                    .offset(x: self.isFocused ? 0 : geometry.size.width, y: 0)
            }
        }
        .frame(height: lineWidth)
    }
}

struct UnderlineTextField: View {

    let title: String
    @Binding var text: String

    let lineWidth: CGFloat

    let defaultColor: UIColor
    let highlightedColor: UIColor

    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void

    @State private var isFocused = false

    init(_ title: String, text: Binding<String>, lineWidth: CGFloat = 1.0, defaultColor: UIColor, highlightedColor: UIColor, onEditingChanged: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = {}) {
        self.title = title
        self._text = text
        self.lineWidth = lineWidth
        self.defaultColor = defaultColor
        self.highlightedColor = highlightedColor
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }

    var body: some View {
        VStack {
            TextField(self.title, text: self.$text, onEditingChanged: {
                self.onEditingChanged($0)
                self.isFocused = $0
            }, onCommit: self.onCommit)
            .padding(.vertical, 2)

            FocusedLine(defaultLineColor: self.defaultColor, highlightedLineColor: self.highlightedColor, isFocused: self.$isFocused)
                .animation(.linear(duration: 0.23))
        }
    }
}

struct UnderlineSecureField: View {

    let title: String
    @Binding var text: String
    @Binding var isFocused: Bool

    let lineWidth: CGFloat

    let defaultColor: UIColor
    let highlightedColor: UIColor

    let onCommit: () -> Void

    init(_ title: String, text: Binding<String>, isFocused: Binding<Bool>, lineWidth: CGFloat = 1.0, defaultColor: UIColor, highlightedColor: UIColor, onCommit: @escaping () -> Void = {}) {
        self.title = title
        self._text = text
        self._isFocused = isFocused
        self.lineWidth = lineWidth
        self.defaultColor = defaultColor
        self.highlightedColor = highlightedColor
        self.onCommit = onCommit
    }

    var body: some View {
        VStack {
            SecureField(self.title, text: self.$text, onCommit: {
                self.onCommit()
                self.isFocused = false
            })
            .onTapGesture {
                self.isFocused = true
            }
            .padding(.vertical, 2)

            FocusedLine(defaultLineColor: self.defaultColor, highlightedLineColor: self.highlightedColor, isFocused: self.$isFocused)
                .animation(.linear(duration: 0.23))
        }
    }
}

struct FocusedTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UnderlineTextField("Email", text: .constant(""), defaultColor: .systemGray4, highlightedColor: .systemBlue)
            UnderlineSecureField("Password", text: .constant(""), isFocused: .constant(true), defaultColor: .systemGray4, highlightedColor: .systemBlue)
        }
    }
}
