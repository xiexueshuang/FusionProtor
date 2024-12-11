//
//  _exampleView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI

struct _exampleView: View {
    @EnvironmentObject var windowManager: WindowManager
    
    var body: some View {
        VStack{
            
            //navigator
            BackButton {
                windowManager.switchWindow(to:.camera)
            }
            
            //content
            VStack {
                
                Text("Waiting for generating 3D model...")
                    .font(.largeTitle)
                Text("If you don't know your ID, please consult the experimenter")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)
                    
                
            }
            .padding()
            
            Spacer()
        }
    }
}

#Preview(windowStyle: .automatic) {
    _exampleView()
}
