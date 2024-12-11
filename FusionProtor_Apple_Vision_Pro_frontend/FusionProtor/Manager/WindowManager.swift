//
//  WindowManager.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/5.
//

import Foundation
import SwiftUI

enum WindowType {
    case welcome
    case designId
    case camera
    case edit
    case prompt
    case confirmDesign
    case split
    case componentImage
    case threeDModel

    
    var rawValue: Int {
        switch self {
        case .welcome:
            return 0
        case .designId:
            return 1
        case .camera:
            return 2
        case .edit:
            return 3
        case .prompt:
            return 4
        case .confirmDesign:
            return 5
        case .split:
            return 6
        case .componentImage:
            return 7
        case .threeDModel:
            return 8
        }
        
    }
}

class WindowManager: ObservableObject {
    private var isNextStep: Bool = true
    @Published var currentTransition: AnyTransition = .push(from:.trailing)
    
    @Published var currentWindow: WindowType = .welcome{
        didSet {
            // print("Old value: \(oldValue)")
            // print("Window has changed!")
        }
        willSet {
            updateTransition()
            // print("Transition has upgraded!")
        }
    }
    
    func switchWindow(to: WindowType){
        if(currentWindow.rawValue > to.rawValue){
            isNextStep = false
            print("返回上一步")
        } else{
            isNextStep = true
            print("进入下一步")
        }
        currentWindow = to
        
    }
    
    func updateTransition() {
        if isNextStep {
            currentTransition = .push(from: .trailing)
        } else {
            currentTransition = .push(from: .leading)
        }
    }
    
    
    // global variables stored
    // @Published var designID = ""
    @Published var designID = "FusionProtor"
    @Published var prompt = "" // 整体prompt，用于2D风格生成
    @Published var styleIDs :[Int] = []
    @Published var finalStyleID: Int = -1
    @Published var componentNum = 3
    @Published var capturedImagePixelBuffer:CVPixelBuffer?
    @Published var modifiedImageURL:URL?
    @Published var denoisingStrength = 0.6
    
    @Published var imagesData_entire:[ImageData]? //各个风格的完整图,index和styleid没有关系！！
    @Published var imagesData_component:[[ImageData]] = [[],[],[],[]] //指定风格的的部件图片,component[i][j]代表指定风格的component i 的第 j 张
    @Published var componentPrompts = ["","","",""] //各个部件prompt，用于3D生成
    @Published var boundingBoxs:[BoundingBoxData] = []//各个component的boundingbox坐标
    @Published var UsdzURLs: [String] = ["","","","","",""]
    @Published var UsdzIds: [String] = ["","","",""]
    @Published var componentSelection:[Int] = [1,1,1,1]
    @Published var selectedSkybox: Skybox = .null
    
    func reset()->Void{
        //prompt = "" // 整体prompt，用于2D风格生成
        prompt = "A movable inspection robot with a rotatable inspection camera and off-road tires."
        styleIDs = []
        finalStyleID = -1
        componentNum = 3
        capturedImagePixelBuffer = nil
        modifiedImageURL = nil
        denoisingStrength = 0.6
        imagesData_entire = nil //各个风格的完整图,index和styleid没有关系！！
        imagesData_component = [[],[],[],[]] //指定风格的的部件图片,component[i][j]代表指定风格的component i 的第 j 张
        componentPrompts = ["","","",""] //各个部件prompt，用于3D生成
        boundingBoxs = []//各个component的boundingbox坐标
        UsdzURLs = ["","","","","",""]
        UsdzIds = ["","","",""]
        componentSelection = [1,1,1,1]
        selectedSkybox = .null
    }
}
