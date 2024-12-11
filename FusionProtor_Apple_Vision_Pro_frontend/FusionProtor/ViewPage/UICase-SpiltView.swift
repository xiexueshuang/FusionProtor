//
//  SpiltView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//

import SwiftUI

struct UICase_SpiltView: View {
    @EnvironmentObject var windowManager: WindowManager
    @State var rectOrigins: [CGPoint] = Array(repeating: initialPoint, count: 4)
    @State var rectSizes: [CGSize] = Array(repeating: initialSize, count: 4)
    @State var activeIndex:Int = 1
    var body: some View {
        VStack{
            
            //navigator
            Navigator(onBack: {
                windowManager.currentWindow = .confirmDesign
            }, onNext: {
                windowManager.currentWindow = .componentImage
            }, nextDisabled: false, title: "Split the component.")
            
            //page content
            HStack(spacing: 20){
                VStack(spacing:20){
                    // image display area
                    ImageDisplayArea()
                    
                    //tip
                    HStack{
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.secondary)
                        Text("Drag the anchor to resize bounding boxes")
                            .foregroundStyle(.secondary)
                    }
                }

                //number control
                NumberControl()
                
            }
            
            Spacer()
        }
    }
    
    func UpdateBoundingbox()->Void{
        var boundingBoxs: [BoundingBoxData] = []
        for i in 0..<windowManager.componentNum-1 {
            let x1 = Int(rectOrigins[i].x) * 3
            let y1 = Int(rectOrigins[i].y) * 3
            let x2 = Int(rectOrigins[i].x + rectSizes[i].width) * 3
            let y2 = Int(rectOrigins[i].y + rectSizes[i].height) * 3

            let coordinates = [x1, y1, x2, y2]
            boundingBoxs.append(BoundingBoxData(coordinate: coordinates))
        }
        print(boundingBoxs)
        windowManager.boundingBoxs = boundingBoxs
    }
    
    func ImageDisplayArea()->some View{
        ZStack {
            //image
            AsyncImage(url: URL(string:"http://refinity-protofusion.pub.hsuni.top:29002/debug_case1.png")) { phase in
                switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 640, height: 360)
                            .cornerRadius(25)
                            .padding()
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.thickMaterial)
                                .frame(width: 640, height: 360)
                                .cornerRadius(12)
                                .padding()
                                .padding(.bottom, 40)
                            Text("Unable to get photo")
                        }
                    @unknown default:
                        EmptyView()
                }
            }
            
            // boundingbox canvas
            BoundingboxCanvas(isDebugMode: false, componentCount:windowManager.componentNum - 1,rectOrigins: $rectOrigins, rectSizes: $rectSizes,activeIndex: $activeIndex)
        }
        .frame(width: 640, height: 360)
        .cornerRadius(25)
    }
    
    func NumberControl()->some View{
        VStack(){
            Spacer()
            
            Text("Number of component you’d like to split")
                .font(.title)
                .padding(.vertical)
            
            HStack(spacing: 36){
                Button(action: {
                    windowManager.componentNum = windowManager.componentNum - 1
                    if(activeIndex < windowManager.componentNum){
                        activeIndex = windowManager.componentNum
                    }
                }){
                    Image(systemName: "minus")
                }
                .disabled(windowManager.componentNum == 1)

                Text(String(windowManager.componentNum))
                    .font(.extraLargeTitle)
                
                Button(action: {
                    windowManager.componentNum = windowManager.componentNum + 1
                }){
                    Image(systemName: "plus")
                }
                .disabled(windowManager.componentNum > 3)
            }

            Spacer()
        }
    }
}


#Preview(windowStyle: .automatic) {
    @Previewable @StateObject var windowManager = WindowManager()
    UICase_SpiltView()
        .transition(windowManager.currentTransition)
        .environmentObject(windowManager)
}
