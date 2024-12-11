////
////  ImmersiveView_1.0.swift
////  FusionProtoer
////
////  Created by 蒋招衢 on 2024/8/16.
////
//
//import SwiftUI
//import RealityKit
//
//struct ImmersiveSkyboxView:View {
//    @State var rootEntity = Entity()
//    var body: some View {
//        Button(action:{
//            rootEntity.updateSkybox(AssetsName: "generatedCase")
//        }){
//            Text("Change")
//        }
//        RealityView{ content in
//            rootEntity.addSkybox(AssetsName: "skyboxExample")
//            content.add(rootEntity)
//        }
//    }
//    
//
//}
//
//#Preview(immersionStyle: .full) {
//    ImmersiveSkyboxView()
//}
//
//extension Entity {
//    // create a createSkyBox function which return a Entity object
//    func addSkybox(AssetsName:String){
//        //Mesh
//        let skyBoxMesh = MeshResource.generateSphere(radius: 1000)
//        
//        //Material
//        //let skyBoxMaterial = SimpleMaterial(color: .systemPink, isMetallic: false)
//        var skyBoxMaterial = UnlitMaterial()
//        
//        do {
//            let skyBoxTexture = try TextureResource.load(named:AssetsName)
//            skyBoxMaterial.color = .init(texture: .init(skyBoxTexture))
//        } catch {
//          print("Failed to load skybox texture: \(error)")
//        }
//        
//        //ModelComponent
//        let modelComponent = ModelComponent(
//            mesh: skyBoxMesh,
//            materials: [skyBoxMaterial]
//        )
//        
//        //Entity
//        self.components.set(modelComponent)
//        //reverse texture surface
//        self.scale *= .init(x: -1, y: 1, z: 1)
//        
//    }
//    
//    func updateSkybox(AssetsName:String){
//
//        guard var modelComponent = self.components[ModelComponent.self] else {
//            fatalError("enable to find ModelComponent")
//        }
//        
//        var skyBoxMaterial = UnlitMaterial()
//        
//        do {
//            let skyBoxTexture = try TextureResource.load(named:AssetsName)
//            skyBoxMaterial.color = .init(texture: .init(skyBoxTexture))
//        } catch {
//          print("Failed to load skybox texture: \(error)")
//        }
//        
//        // 更新模型组件中的材质
//        modelComponent.materials = [skyBoxMaterial]
//            
//        // 将更新后的组件重新设置回实体
//        self.components[ModelComponent.self] = modelComponent
//    }
//}
