//
//  ListPicker.swift
//  ViewSample
//
//  Created by hokuron on 2020/03/01.
//

import SwiftUI

struct ListPicker: View {

    @Binding var selection: Int?

    @State private var editMode = EditMode.inactive

    var body: some View {
        VStack {
            Text("sel: \(selection ?? 0)")

            List(1...5, id: \.self, selection: $selection) {
                Text("Avocado #\($0)").tag($0)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                self.editMode = .active
            }
        }
        .environment(\.editMode, $editMode)
    }
}

extension ListPicker {

    init(selection: Binding<Int>) {
        self.init(selection: Binding(selection))
    }
}

struct ListPicker_Previews: PreviewProvider {
    static var previews: some View {
        ListPicker(selection: .constant(2))
    }
}
