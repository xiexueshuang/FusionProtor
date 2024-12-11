////
////  ImmersiveView_3.0.swift
////  FusionProtoer
////
////  Created by 蒋招衢 on 2024/8/16.
////
//
//import SwiftUI
//import RealityKit
//
//struct ImmersiveSkyboxView:View {
//    
//    var body: some View {
//        let rootEntity = Entity()
//        
//        // 添加一个小球以查看光照效果
//        let sphere = ModelEntity(
//            mesh: .generateSphere(radius: 0.25),
//            materials: [SimpleMaterial(color: .white, isMetallic: true)]
//        )
//        
//        Button(action:{
//            Task{
//                do {
//                    let environmentResource = try await EnvironmentResource(named: "shanghai")
//                    let probe = VirtualEnvironmentProbeComponent.Probe(environment: environmentResource)
//                    let probeComponent = VirtualEnvironmentProbeComponent(source: .single(probe))
//                    sphere.components.set(probeComponent)
//                } catch {
//                    print("Failed to load resources: \(error)")
//                }
//            }
//
//        }){
//            Text("Change")
//        }
//        RealityView { content in
//            
//            let skyBoxMesh = MeshResource.generateSphere(radius: 1000)
//
//            //Material
//            var skyBoxMaterial = UnlitMaterial()
//
//            do {
//                let skyBoxTexture = try await TextureResource.init(named:"skyboxExample")
//                skyBoxMaterial.color = .init(texture: .init(skyBoxTexture))
//            } catch {
//              print("Failed to load skybox texture: \(error)")
//            }
//
//            //ModelComponent
//            let modelComponent = ModelComponent(
//                mesh: skyBoxMesh,
//                materials: [skyBoxMaterial]
//            )
//
//            //Entity
//            rootEntity.components.set(modelComponent)
//            
//            //reverse texture surface
//            rootEntity.scale *= .init(x: -1, y: 1, z: 1)
//            
//            content.add(rootEntity)
//            
//            
//            do {
//                let environmentResource = try await EnvironmentResource(named: "Sunlight")
//                let probe = VirtualEnvironmentProbeComponent.Probe(environment: environmentResource)
//                let probeComponent = VirtualEnvironmentProbeComponent(source: .single(probe))
//                sphere.components.set(probeComponent)
//            } catch {
//                print("Failed to load resources: \(error)")
//            }
//            
//            content.add(sphere)
//            
//        }
//    }
//}
//
//
//#Preview(immersionStyle: .automatic) {
//    ImmersiveSkyboxView()
//}
