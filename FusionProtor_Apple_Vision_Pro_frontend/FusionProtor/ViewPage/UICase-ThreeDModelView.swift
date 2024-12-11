//
//  SuccessView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI
import RealityKit
import RealityKitContent
import QuickLook

struct UICase_ThreeDModelView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State private var hasFinishedGeneration:Bool = true
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var isShowRetry = true
    
    var teaserCase_UsdzURLs = ["http://refinity-protofusion.pub.hsuni.top:29002/3_3.usdz",
                               "http://refinity-protofusion.pub.hsuni.top:29002/3_1.usdz",
                               "http://refinity-protofusion.pub.hsuni.top:29002/3_2.usdz"]
    var body: some View {
        VStack{
            ZStack{
                //navigator
                Navigator(onBack: {
                    windowManager.currentWindow = .componentImage
                }, onNext: {
                   
                }, nextDisabled: true, hasNext: false, title: "Check your component model.")
                .onAppear(perform: {
                    for i in 0..<3 {
                        windowManager.UsdzURLs[i] = teaserCase_UsdzURLs[i]
                    }
                    
                })
                
                // EnvironmentPicker
                EnvironmentPicker()
                    .padding(.leading,1060)
                    .padding(.top,40)
                    .environmentObject(windowManager)
            }
            
            //content
            VStack {
                // guide title
                if(hasFinishedGeneration){
                    //tip
                    HStack{
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.secondary)
                        Text("You can drag the model out of the window and preview it in space")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom)
                    
                    //3D model display area
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 80){
                            Spacer()
                            ForEach(0..<3, id: \.self) { i in
                                VStack{
                                    ComponentModelViewer(
                                        url: windowManager.UsdzURLs[i], order: i + 1,
                                        isShowRetry: $isShowRetry
                                    )
                                    .environmentObject(windowManager)
                                    // debug info
//                                    Text(windowManager.UsdzIds[i])
                                }
                                
                            }
                            Spacer()
                        }
                    }

                    //tail guide
                    if(hasFinishedGeneration){
                        HStack{
                            Image("blenderLogo")
                                .frame(width: 64)
                            VStack(alignment: .leading) {
                                Text("Move on your work in Blender.")
                                Text("Click “import” in plugin to import all components at once")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical,40)
                    }

                }
                else{
                    VStack{
                        Spacer()
                        ProgressView()
                        Text("Waiting for generating 3D model...")
                        Text("About 3 minites left")
                        Spacer()
                    }
                }
            }
            .padding()
            
            Spacer()
        }
    }
    

}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    UICase_ThreeDModelView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
