//
//  SettingsView.swift
//  eintodo
//
//  Created by anh :) on 20.12.21.
//

import SwiftUI
import Foundation

//Add Date to AppStorage, because AppStorage as default does not support the type Date
extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}
struct SettingsView: View {
    @AppStorage("deadlineTime") private var deadlineTime: Date = Date()
    var body: some View {
        ZStack{
            VStack(spacing: 20){
                LeftText(text: "Einstellungen", font: .title, fontWeight: .bold)
                DatePicker("Standard-Erinnerungszeit für Fällig", selection: $deadlineTime, displayedComponents: .hourAndMinute)
                Spacer()
            }
            .padding()
        }
        .frame(width: Sizes.defaultSheetWidth, height: Sizes.defaultSheetHeight)
    }
}
