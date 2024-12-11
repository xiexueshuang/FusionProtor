//
//  ComponentImageView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//


import SwiftUI

struct videoCase_ComponentImageView: View {
    @EnvironmentObject var windowManager: WindowManager
    
    @State private var isWaiting = false
    @State private var isShowRetry = false
    var body: some View {
        VStack{
            
            //navigator
            Navigator(onBack: {
                windowManager.switchWindow(to:.split)
            }, onNext: {
                windowManager.switchWindow(to:.threeDModel)
            }, nextDisabled: isPromptBlank(), title: "Select component image.")
            .onAppear(perform: {
                if(windowManager.imagesData_component.allSatisfy({ $0.isEmpty })){
                    print("未存在数据")
                    isWaiting = true
                    UpdateComponentImage()
                }
            })
            
            //page content
            ZStack{
                if(isWaiting){
                    VStack{
                        Spacer()
                        ProgressView()
                        Text("Uploading data and processing...")
                        if(isShowRetry){
                            Button(action: {
                                UpdateComponentImage()
                                isWaiting = true
                                isShowRetry = false
                            }, label: {
                                Text("Retry")
                            })
                        }else{
                            Text("About 3 minites left")
                        }
                        Spacer()
                    }
                }else{
                    HStack{
                        Spacer()
                        ScrollView(.vertical){
                            VStack(spacing: 40){
                                ForEach(0..<windowManager.componentNum, id: \.self) { index in
                                    ComponentSelector(
                                        prompt: $windowManager.componentPrompts[index], componentOrder: index + 1,
                                        images:windowManager.imagesData_component[index], selectedNum: windowManager.componentSelection[index],
                                        onClick: chooseComponentImage,
                                        onRegenerate: UpdateComponentImage
                                    )
                                }
                            }
                            .padding(40)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
    
    func isPromptBlank()->Bool{
        for i in 0..<windowManager.componentNum {
            if(windowManager.componentPrompts[i] == "") {
                return true
            }
        }
        return false
    }
    
    func chooseComponentImage(order:Int, selectIndex: Int){
//        print(order,selectIndex)
        windowManager.componentSelection[order-1] = selectIndex
    }
    
    func UpdateComponentImage()->Void{
        windowManager.imagesData_component = [
            [
             ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/2_3.png",styleId: 1),
             ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/2_4.png",styleId: 1)
            ],
            [
             ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/2_5.png",styleId: 1),
             ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/2_6.png",styleId: 1)
            ],
            [
             ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/2_1.png",styleId: 1),
             ImageData(imageId: "0917_3",url: "http://refinity-protofusion.pub.hsuni.top:29002/2_2.png",styleId: 1)
            ]
        ]
        windowManager.componentPrompts = ["The fuselage of a mobile robot","Rotatable intelligent detection head of mobile robot","Off-road tire of mobile robot"]
            
        if(windowManager.imagesData_component[0].isEmpty){
            isShowRetry = true
        }else{
            isWaiting = false
        }
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    videoCase_ComponentImageView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
