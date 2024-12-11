//
//  ConfirmDesignView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI

struct ConfirmDesignView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State var isShowRetry = false
    var body: some View {
        VStack{
            //navigator
            Navigator(onBack: {
                windowManager.switchWindow(to:.confirmDesign)
                windowManager.finalStyleID = -1
            }, onNext: {
                windowManager.switchWindow(to:.componentImage)
            }, nextDisabled: windowManager.finalStyleID == -1, title: "Confirm your design - " + windowManager.prompt)
            
            // Page content
            VStack(spacing: 40) {
                Spacer()
                
                ZStack{
                    //progressive
                    if(windowManager.imagesData_entire == nil){
                        VStack{
                            ProgressView()
                            Text("Uploading the image and processing...")
                            if(isShowRetry){
                                Button(action:{
                                    UpdateImage()
                                }){
                                    Text("Retry")
                                }
                            }else{
                                Text("About 2 minites left")
                            }
                        }
                    }

                    // Image display area
                    HStack{
                        ScrollView(.horizontal){
                            HStack(spacing: 60) {
                                ForEach(windowManager.styleIDs, id: \.self) { styleID in
                                    if let image = windowManager.imagesData_entire?.first(where: { $0.styleId == styleID }) {
                                        OnlineImageView(image: image, styleID: styleID, finalStyleID: $windowManager.finalStyleID)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
                }
                Spacer()
            }
        }
        .onAppear(perform: {
            isShowRetry = false
            UpdateImage()
        })
    }
    func UpdateImage()->Void{
        isShowRetry = false
        GenerateCandidateEntireImage(
            image:windowManager.modifiedImageURL?.toBase64String() ?? "base64 example",
            styleId:windowManager.styleIDs,
            prompt: windowManager.prompt,
            denoising_strength: windowManager.denoisingStrength,
            user_token: windowManager.designID)
        {
            response in
//                print("response:", response!)
                if let response = response {
                    print("Image url: \(response.images[0].url)")
                    DispatchQueue.main.async {
                        windowManager.imagesData_entire = response.images
                    }
                } else {
//                    print("Failed to generate candidate entire image.")
                    isShowRetry = true
                }
        }
    }
}

struct OnlineImageView: View {
    let image: ImageData
    let styleID: Int
    @Binding var finalStyleID: Int

    var body: some View {
        VStack {
            // Online image

            ZStack {
                AsyncImage(url: URL(string: image.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 560, height: 315)
                    case .success(let image):
                        Button(action:{
                            finalStyleID = styleID
                        }){
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 560, height: 315)
                                .cornerRadius(25)
                                .hoverEffect()
                        }
                        .buttonBorderShape(.roundedRectangle(radius: 25))
                        .frame(width: 560, height: 315)
                        .buttonStyle(PlainButtonStyle())
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.thickMaterial)
                                .frame(width: 560, height: 315)
                                .cornerRadius(12)
                                .padding(.bottom, 40)
                            Text("Unable to get photo")
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .inset(by: 1)
                        .stroke(Color.white, lineWidth: finalStyleID == styleID ? 4 : 0)
                )
            }
            
            // Selected icon & style tag
            HStack(spacing: 20) {
                // Selected icon
                Image(systemName: "checkmark.circle.fill")
                    .opacity(finalStyleID == styleID ? 1 : 0)
                    .font(.largeTitle)
                    .transition(.push(from: .leading))
                    .animation(.easeInOut, value: finalStyleID)

                // Style tag
                Text("Style" + String(styleID))
                    .font(.largeTitle)
                    .padding()
                    .padding(.leading, finalStyleID == styleID ? -10 : -40)
                    .transition(.push(from: .leading))
                    .animation(.easeInOut, value: finalStyleID)
            }
            .padding(.top,8)

            // Regenerate button
            HStack {
                Spacer()

                ButtonWithIcon(onBack: {
                    // Regenerate action
                }, iconName: "gobackward", text: "Regenerate")
                .disabled(true)

                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    ConfirmDesignView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
