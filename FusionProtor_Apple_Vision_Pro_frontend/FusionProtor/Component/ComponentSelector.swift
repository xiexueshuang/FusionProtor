//
//  ComponentSelector.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/7.
//
import SwiftUI



struct ComponentSelector: View {
    // let images = ["generatedCase", "generatedCase"] // 图片名称数组
    @Binding var prompt:String
    var componentOrder: Int
    var images:[ImageData]
    var selectedNum:Int = 1
    var onClick: (Int,Int) -> Void = {_,_ in }
    var onRegenerate:()->Void
    var body: some View {
        HStack(){
            VStack{
                Text("Component"+String(componentOrder))
                    .font(.title)
                
                TextField("Enter your prompt", text: $prompt)
                    .frame(width: 200)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.trailing, 40)

            ScrollView(.horizontal){
                HStack(spacing: 20) {
                    
                    //image galary
                    ForEach(images.indices, id: \.self) { index in
                        Button(action:{
                            onClick(componentOrder,index+1)
                        }){
                            ZStack{
                                AsyncImage(url: URL(string: images[index].url)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 320,height: 180)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .inset(by: 1)
                                                    .stroke(.white, lineWidth:  selectedNum == index+1 ? 2 : 0)
                                            )
                                    case .failure:
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.thickMaterial)
                                                .frame(width: 320, height: 180)
                                                .cornerRadius(12)
                                                .padding(.bottom, 40)
                                            Text("Unable to get photo")
                                        }
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                //check mark
                                if(selectedNum == index+1){
                                    HStack{
                                        Spacer()
                                        VStack{
                                            Spacer()
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title)
                                                .padding(.trailing,20)
                                                .padding(.bottom,20)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: 320,height: 180)
                        .buttonBorderShape(.roundedRectangle(radius: 12))
                        .buttonStyle(DefaultButtonStyle())
                    }
                    
                    //regeneration button
                    Button(action: {
                        onRegenerate()
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.thickMaterial)
                                .frame(width: 320, height: 180)
                            VStack(spacing: 12){
                                Image(systemName: "plus")
                                    .font(.title)
                                Text("Generate more")
                            }
                        }
                    }
                    .frame(width: 320,height: 180)
                    .buttonBorderShape(.roundedRectangle(radius: 12))
                    
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    @Previewable @State var prompt = "Enter your prompt here"
    ComponentSelector(prompt: $prompt, componentOrder: 1, images:[], selectedNum: 1, onRegenerate: {})
}
