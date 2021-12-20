//
//  SettingsView.swift
//  eintodo
//
//  Created by anh :) on 20.12.21.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack{
            VStack{
                Text("SettingsView")
            }
        }
        .frame(width: Sizes.defaultSheetWidth, height: Sizes.defaultSheetHeight)
    }
}
