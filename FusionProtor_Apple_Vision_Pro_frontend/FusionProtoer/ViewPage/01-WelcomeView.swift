//
//  WelcomeView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/6.
//
import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var windowManager: WindowManager
    var body: some View {
        Text("Welcome to use FusionProtoer")
            .font(.largeTitle)
            .padding(.bottom, 40)
        HStack{
            // left
            VStack(alignment: .leading) {
                Text("Before you get started...")
                    .font(.largeTitle)
                    .padding(.vertical)
                
                HStack{
                    Image("blenderLogo")
                        .frame(width: 64)
                    VStack(alignment: .leading) {
                        Text("Open Blender on Mac and start screen mirroring")
                        Text("Test the mouse, keyboard, or touchpad connected to the Mac.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical)
                
                HStack{
                    Image(systemName:"macwindow")
                        .font(.system(size: 36))
                        .frame(width: 64)
                    VStack(alignment: .leading) {
                        Text("Arrange the window in appropriate position and scale ")
                        Text("Ensure that you can comfortably view all the windows in your workspace.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical)
                
                HStack{
                    Image(systemName:"rotate.3d")
                        .font(.largeTitle)
                        .frame(width: 64)
                    VStack(alignment: .leading) {
                        Text("Familiarize yourself with interaction of 3D models")
                        Text("Using gestures to manipulate 3D models which Airdrops to you by experimenters.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical)
            }
            .padding(.trailing,80)
            
            // right pannel
            VStack{
                Image("helper")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 260)
                    .cornerRadius(12)
                Text("Open FusionProtoer, Finder and Blender on Mac(screen mirroring) ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
        }
        .padding(.bottom, 40)
        
        ButtonWithIcon(onBack: {
            windowManager.switchWindow(to:.designId)
        }, iconName: "checkmark.circle.fill", text: "I’m ready!")
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    WelcomeView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
