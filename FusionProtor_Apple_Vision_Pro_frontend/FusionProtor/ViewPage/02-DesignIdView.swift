//
//  DesignIdView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/6.
//

import SwiftUI

struct DesignIDView: View {
    @EnvironmentObject var windowManager: WindowManager
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    var body: some View {
        VStack{
            
            //navigator
            BackButton {
                windowManager.switchWindow(to:.welcome)
            }
            
            Spacer()
            
            //content
            VStack {
                
                Text("Enter your Design ID")
                    .font(.largeTitle)
                Text("If you don't know your ID, please consult the experimenter")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                
                TextField("Enter your designID", text: $windowManager.designID)
//                    .onSubmit {
//                        print("designID: \(windowManager.designID)")
//                    }
                    .frame(width: 500)
                    .textFieldStyle(.roundedBorder)
                    
                    
                Button{
                    print("designID被设置为：",windowManager.designID)
                    windowManager.switchWindow(to:.camera)
                    Task {
                        _ = await openImmersiveSpace(id: "camera")
                    }
                } label: {
                    Text("OK")
                }
                .disabled(windowManager.designID == "")
                .padding()
                
            }
            .padding()
            
            Spacer()
        }
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    DesignIDView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
   
}
