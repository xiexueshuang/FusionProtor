//
//  PromptView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI

struct PromptView: View {
    @EnvironmentObject var windowManager: WindowManager
    let styles = [
            (name: "style1", id: 1),
            (name: "style2", id: 2),
            (name: "style3", id: 3),
            (name: "style4", id: 4),
            (name: "style5", id: 5),
            (name: "style6", id: 6),
            (name: "style7", id: 7),
            (name: "style8", id: 8),
            (name: "style9", id: 9),
            (name: "style10", id: 10),
            (name: "style11", id: 11),
            (name: "style12", id: 12),
            (name: "style13", id: 13),
            (name: "style14", id: 14),
            (name: "style15", id: 15),
            (name: "style16", id: 16)
        ]
    
    var body: some View {
        VStack(alignment: .leading){
            
            //navigator
            Navigator(onBack: {
                windowManager.switchWindow(to:.edit)
            },onNext: {
                windowManager.switchWindow(to:.confirmDesign)
                windowManager.imagesData_entire = nil
            },nextDisabled: windowManager.prompt == "" || windowManager.styleIDs.count == 0, title: "Edit prompt & style.")
            
            //content
            VStack(alignment: .leading) {
                HStack{
                    // prompt
                    VStack(alignment: .leading){
                        Text("Describe your design in a few words:")
                            .font(.largeTitle)
                            .padding(.bottom, 20)
                        
                        TextField("Enter your prompt", text: $windowManager.prompt)
                            .frame(width: 600)
                            .textFieldStyle(.roundedBorder)
                            .padding(.bottom,40)
                    }
                    Spacer()
                    VStack(alignment: .leading){
                        Text("Denoising Strength:        "+String(format: "%.2f",windowManager.denoisingStrength))
                            .font(.largeTitle)
                            .padding(.bottom, 20)
                        Slider(
                            value: $windowManager.denoisingStrength,
                            in: 0...1
                        ){
                            
                        } minimumValueLabel: {
                            Text("0")
                                .font(.title)
                        } maximumValueLabel: {
                            Text("1")
                                .font(.title)
                        }
                        .frame(width: 400)
                        .padding(.bottom,60)
                    }
                    Spacer()
                }

                
                // style
                Text("Select your favourite styles:")
                    .font(.largeTitle)
                
                ScrollView(.horizontal){
                    HStack(spacing: 20){
                        ForEach(styles, id: \.id) { style in
                            Button(action: {
                                handleImageTap(index: style.id)
                            }){
                                StyleImageViewChip(imageBundleName: style.name, styleText: "Style" + String(style.id), isSelected: windowManager.styleIDs.contains(style.id))
                            }
                            .cornerRadius(25)
                            .buttonStyle(PlainButtonStyle())

                        }
                        .padding(.bottom,20)
                    }
                }
                
            }
            .padding(40)
            
            Spacer()
        }
    }
    
    func handleImageTap(index: Int){
        if(windowManager.styleIDs.contains(index)){
            windowManager.styleIDs.removeAll { $0 == index }
        }else{
            windowManager.styleIDs.append(index)
        }
        windowManager.styleIDs.sort()
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    PromptView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
