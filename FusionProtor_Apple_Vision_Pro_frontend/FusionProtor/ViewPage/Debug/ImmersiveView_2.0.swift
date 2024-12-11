//
//  ImmersiveView_2.0.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/16.
//

import SwiftUI
import RealityKit

//struct ImmersiveSkyboxView:View {
//    var body: some View {
//        
//        let rootEntity = Entity()
//        
//        // 添加一个小球以查看光照效果
//        let sphere = ModelEntity(
//            mesh: .generateSphere(radius: 0.25),
//            materials: [SimpleMaterial(color: .white, isMetallic: true)]
//        )
//        
//        RealityView { content in
//            
//            rootEntity.addSkybox(AssetsName: "skyboxExample")
//            content.add(rootEntity)
//            
//            
//            await sphere.addImageBasedLight(AssetsName: "skyboxExample")
//            content.add(sphere)
//            
//        }
//    }
//    func makeWorld() -> Entity {
//        let world = Entity()
//        world.components[WorldComponent.self] = .init()
//        Task{
//            guard let environment = try? await EnvironmentResource.init(named: "skyboxExample") else{
//                print("load skybox failed")
//                return
//            }
//            world.components[ImageBasedLightComponent.self] = .init(source: .single(environment), intensityExponent: 12)
//            world.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: world)
//        }
//        return world
//    }
//    
//}



//#Preview(immersionStyle: .automatic) {
//    ImmersiveSkyboxView()
//}

extension Entity {
    
    func addImageBasedLight(AssetsName:String) async {
        guard let environment = try? await EnvironmentResource(named: AssetsName) else {
            return
        }

        self.components.set(ImageBasedLightComponent(source: .single(environment)))
        self.components.set(ImageBasedLightReceiverComponent(imageBasedLight: self))
    }
    
    // create a createSkyBox function which return a Entity object
    func addSkybox(AssetsName:String){
        //Mesh
        let skyBoxMesh = MeshResource.generateSphere(radius: 1000)

        //Material
        //let skyBoxMaterial = SimpleMaterial(color: .systemPink, isMetallic: false)
        var skyBoxMaterial = UnlitMaterial()

        do {
            let skyBoxTexture = try TextureResource.load(named:AssetsName)
            skyBoxMaterial.color = .init(texture: .init(skyBoxTexture))
        } catch {
          print("Failed to load skybox texture: \(error)")
        }

        //ModelComponent
        let modelComponent = ModelComponent(
            mesh: skyBoxMesh,
            materials: [skyBoxMaterial]
        )

        //Entity
        self.components.set(modelComponent)
        //reverse texture surface
        self.scale *= .init(x: -1, y: 1, z: 1)

    }

    func updateSkybox(AssetsName:String){

        guard var modelComponent = self.components[ModelComponent.self] else {
            fatalError("enable to find ModelComponent")
        }

        var skyBoxMaterial = UnlitMaterial()

        do {
            let skyBoxTexture = try TextureResource.load(named:AssetsName)
            skyBoxMaterial.color = .init(texture: .init(skyBoxTexture))
        } catch {
          print("Failed to load skybox texture: \(error)")
        }

        // 更新模型组件中的材质
        modelComponent.materials = [skyBoxMaterial]

        // 将更新后的组件重新设置回实体
        self.components[ModelComponent.self] = modelComponent
    }
}
