//
//  BackButton.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/6.
//

import SwiftUI

struct BackButton: View {
    var onBack: () -> Void
        
    var body: some View {
        HStack{
            ButtonWithIcon(onBack: onBack, iconName: "arrow.left", text: "Back")
            .padding(.leading,40)
            .padding(.top,40)
            Spacer()
        }
    }
}
