//
//  ImageViewChip.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI

struct StyleImageViewChip: View {
    
    var imageBundleName: String
    var styleText: String
    var isSelected: Bool
    
    var body: some View {
        VStack(spacing: 20){
            ZStack{
                Image(imageBundleName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .cornerRadius(25)
                
                //mask
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(.clear)
                    .background(
                        maskGradient
                    )
                    .frame(width: 300, height: 200)
                    .cornerRadius(25)
                
                // style name
                HStack{
                    VStack{
                        Spacer()
                        Text(styleText)
                            .font(.title)
                    }.padding()
                    Spacer()
                }.padding()

            }
            .hoverEffect()
            .frame(height: 200)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                .inset(by: 1)
                .stroke(.white, lineWidth: isSelected ? 2 : 0)
            )
            .cornerRadius(25)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .opacity(isSelected ? 1 : 0)
        }
        
    }
}


