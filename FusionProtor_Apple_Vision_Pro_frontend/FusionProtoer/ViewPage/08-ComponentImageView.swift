//
//  ComponentImageView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//


import SwiftUI

struct ComponentImageView: View {
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
        let imageId = windowManager.imagesData_entire?.first(where: { $0.styleId == windowManager.finalStyleID })?.imageId
        
        //debug
//        let boundingBox: [BoundingBoxData] = [BoundingBoxData(coordinate: [100,200,50,50])]
        
        GenerateComponentImage(
            imageId: imageId ?? "",
            componentCount: windowManager.componentNum,
            boundingBox: windowManager.boundingBoxs,
            user_token: windowManager.designID
//            imageId: "exampleId_car_1.png",
//            componentCount: 2,
//            boundingBox: boundingBox,
//            user_token: "karya"
        ){  response in
            if let response = response {
//                print(response)
                DispatchQueue.main.async {
                    for i in 0...response.componentImages.count-1 { // response.componentImages.count 其实也是 windowManager.componentNum
                        windowManager.imagesData_component[i].append(contentsOf: response.componentImages[i].Images)
                    }
                    if(windowManager.imagesData_component[0].isEmpty){
                        isShowRetry = true
                    }else{
                        isWaiting = false
                    }
                }
            } else {
//                print("Failed to generate candidate component image.")
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    ComponentImageView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
