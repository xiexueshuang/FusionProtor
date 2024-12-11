//
//  Navigator.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI

struct Navigator: View {
    var onBack: () -> Void
    var onNext: () -> Void
    var nextDisabled: Bool
    var hasNext: Bool = true
    var title: String
    var body: some View {
        ZStack{
            HStack{
                ButtonWithIcon(onBack: onBack, iconName: "arrow.left", text: "Back")
                .padding(.leading,40)
                .padding(.top,40)
                Spacer()
            }

            
            HStack{
                Spacer()
                Text(title)
                    .font(.largeTitle)
                    .padding(.top,40)
                    .frame(width: 800)
                Spacer()
            }

            if(hasNext) {
                HStack{
                    Spacer()
                    
                    ButtonWithIcon(onBack: onNext, iconName: "arrow.right", text: "Next")
                        .padding(.trailing,40)
                        .padding(.top,40)
                        .disabled(nextDisabled)
                }
            }
        }
    }
}
