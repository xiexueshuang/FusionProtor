//
//  ImmersiveView.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/17.
//

import SwiftUI
import RealityKit

struct ImmersiveSkyboxView:View {
    var assetsName:String
    var body: some View {
        
        let rootEntity = Entity()
        
        // 添加一个小球以查看光照效果
//        let sphere = ModelEntity(
//            mesh: .generateSphere(radius: 0.25),
//            materials: [SimpleMaterial(color: .white, isMetallic: true)]
//        )
        
        RealityView { content in
            
            rootEntity.addSkybox(AssetsName: assetsName)
            content.add(rootEntity)
            
            
//            await sphere.addImageBasedLight(AssetsName: assetsName)
//            content.add(sphere)
            
        }
    }
}

#Preview(immersionStyle: .automatic) {
    ImmersiveSkyboxView(assetsName:"skyboxExample")
}
