//
//  FusionProtoerApp.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/5.
//

import SwiftUI

@main
struct FusionProtoerApp: App {
    @StateObject private var windowManager = WindowManager()
    
    var body: some Scene {
//        ImmersiveSpace{
//            ImmersiveSkyboxView()
//        }
        
        WindowGroup {
            Group{
                switch windowManager.currentWindow {
                    case .welcome:
                        WelcomeView()
//                    UICase_SpiltView()
                            .transition(windowManager.currentTransition)
                    case .designId:
                        DesignIDView()
//                    TeaserCase_ThreeDModelView()
                            .transition(windowManager.currentTransition)
                    case .camera:
                        videoCase_CameraView()
                            .transition(windowManager.currentTransition)
                    case .edit:
                        EditView()
                            .transition(windowManager.currentTransition)
                    case .prompt:
                        PromptView()
                            .transition(windowManager.currentTransition)
                    case .confirmDesign:
                        videoCase_ConfirmDesignView()
                        //ConfirmDesignView()
                            .transition(windowManager.currentTransition)
                    case .split:
                        UICase_SpiltView()
                        //SpiltView()
                            .transition(windowManager.currentTransition)
                    case .componentImage:
                        videoCase_ComponentImageView()
                            .transition(windowManager.currentTransition)
                    case .threeDModel:
                        UICase_ThreeDModelView()
                        // ThreeDModelView()
                            .transition(windowManager.currentTransition)
                }
                // TeaserCase_ThreeDModelView()
                // UICase_SpiltView()
            }
            .environmentObject(windowManager)
            .animation(.easeInOut, value: windowManager.currentWindow)
        }

        ImmersiveSpace(id: "camera"){
            EmptyView()
        }
        ImmersiveSpace(id: "mountain"){
            ImmersiveSkyboxView(assetsName: "skyboxExample")
        }
        ImmersiveSpace(id: "shanghai"){
            ImmersiveSkyboxView(assetsName: "shanghai")
        }
        ImmersiveSpace(id: "space"){
            ImmersiveSkyboxView(assetsName: "Sunlight")
        }
        
    }

}
