//
//  ButtonWithIcon.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI

struct ButtonWithIcon: View {
    var onBack: () -> Void
    var iconName:String
    var text:String
    
    var body: some View {
        Button(action: onBack) {
            HStack{
                Image(systemName: iconName) // 使用SF Symbols图标
                    .font(.title) // 设置图标大小
                    .padding(.trailing, 12)
                Text(text) // 按钮旁边的文本
                    .font(.title)
            }
            .padding()
        }
    }
}
