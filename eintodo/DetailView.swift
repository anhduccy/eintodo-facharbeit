//
//  DetailView.swift
//  eintodo
//
//  Created by anh :) on 12.12.21.
//

import SwiftUI

struct DetailView: View {
    @Binding var showDetailView: Bool
    @State var title: String
    @State var deadline: Date?
    @State var notification: Date?
    @State var isDone: Bool
    var body: some View {
        Text(title)
    }
}
