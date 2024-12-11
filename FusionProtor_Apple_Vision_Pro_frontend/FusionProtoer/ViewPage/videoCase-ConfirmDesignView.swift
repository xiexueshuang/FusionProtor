//
//  ConfirmDesignView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI

struct videoCase_ConfirmDesignView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State var isShowRetry = false
    var body: some View {
        VStack{
            //navigator
            Navigator(onBack: {
                windowManager.switchWindow(to:.prompt)
                windowManager.finalStyleID = -1
            }, onNext: {
                windowManager.switchWindow(to:.split)
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
        windowManager.imagesData_entire = [
            ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/1_1.png",styleId: 1),
            ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/1_3.png",styleId: 3),
            ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/1_5.png",styleId: 5),
            ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/1_6.png",styleId: 6)
        ]
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    videoCase_ConfirmDesignView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
