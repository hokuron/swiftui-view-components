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
    @State private var isUsernameFieldFocused = false
    @State private var isPasswordFieldFocused = false

    var body: some View {
        VStack(spacing: 24) {
            UnderlineTextField(title: "Username",
                               text: $username,
                               isFocused: $isUsernameFieldFocused,
                               onEditingChanged: { isChanged in
                                   if isChanged {
                                       self.isPasswordFieldFocused = !self.password.isEmpty
                                   }
                                   return !self.username.isEmpty
                               })
            UnderlineSecureField(title: "Password", text: $password, isFocused: $isPasswordFieldFocused) {
                !self.password.isEmpty
            }
        }
        .padding(.horizontal)
    }
}

private struct CircularSliderSampleView: View {

    @State private var value = 26.0
    @State private var step = 0.0

    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    var body: some View {
        ZStack(alignment: .circularSliderCenter) {
            CircularSlider(value: $value, range: 1...100, step: step)

            VStack(spacing: 24) {
                Text(formatted(value))
                    .font(.system(size: 80, design: .monospaced))
                Stepper("Step: \(formatted(step))", value: $step, in: 0...100, step: 0.1)
                    .padding(.horizontal, 96)
            }
            .alignmentGuide(VerticalAlignment.circularSliderCenter) { $0[VerticalAlignment.center] }
        }
        .padding(.horizontal)
    }

    private func formatted(_ value: Double) -> String {
        return numberFormatter.string(from: NSNumber(value: value))!
    }
}

struct ContentView: View {

    private let components = [
        "UnderLineTextField": AnyView(LoginView()),
        "HalfCircleSlider": AnyView(CircularSliderSampleView()),
    ]

    var body: some View {
        NavigationView {
            List(components.keys.sorted(), id: \.self) { key in
                NavigationLink(key, destination: self.components[key]!)
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
