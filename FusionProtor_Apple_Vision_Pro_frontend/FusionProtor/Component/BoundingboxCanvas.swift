//
//  BoundingboxCanvas.swift
//  FusionProtoer
//
//  Created by 蒋招衢 on 2024/8/13.
//

import SwiftUI
import AVFoundation

let initialPoint = CGPoint(x: 100, y: 100)
let initialSize = CGSize(width: 150, height: 100)

struct BoundingboxCanvas: View {
    var isDebugMode: Bool
    var componentCount: Int
    @Binding var rectOrigins: [CGPoint]
    @Binding var rectSizes: [CGSize]
    @Binding var activeIndex: Int
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<componentCount, id: \.self) { i in
                    DraggableRectangleView(
                        rectOrigin: Binding(
                            get: { rectOrigins[i] },
                            set: { rectOrigins[i] = $0 }
                        ),
                        rectSize: Binding(
                            get: { rectSizes[i] },
                            set: { rectSizes[i] = $0 }
                        ),
                        isDebugMode: isDebugMode,
                        index: i,
                        isActive: activeIndex == i,
                        activeIndex: $activeIndex // 传递 activeIndex 绑定
                    )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0)
                    .stroke(.blue, lineWidth: isDebugMode ? 2 : 0)
            )
            
            // debug info
            if isDebugMode {
                HStack(spacing: 20) {
                    if let firstRectOrigin = rectOrigins.first,
                       let firstRectSize = rectSizes.first {
                        Text("x: \(firstRectOrigin.x)")
                        Text("y: \(firstRectOrigin.y)")
                        Text("width: \(firstRectSize.width)")
                        Text("height: \(firstRectSize.height)")
                        Text("active index: \(activeIndex + 1)")
                    }
                }
            }
        }
    }
}

struct DraggableRectangleView: View {
    @Binding var rectOrigin: CGPoint
    @Binding var rectSize: CGSize
    var isDebugMode: Bool
    var index: Int
    var isActive: Bool
    @Binding var activeIndex: Int
    
    var body: some View {
        ZStack {
            Text(String(index + 1))
                .foregroundColor(Color.white)
                .font(.extraLargeTitle2)
                .bold()
                .position(x: rectOrigin.x + rectSize.width / 2, y: rectOrigin.y + rectSize.height / 2)
            
            // Draw the rectangle
            Rectangle()
                .stroke(isActive ? Color.blue : Color.white.opacity(0.1), lineWidth: 2)
                .transition(.opacity)
                .animation(.easeInOut, value: activeIndex)
                .background(isActive ? Color.blue.opacity(0.1) : Color.white.opacity(0.1))
                .frame(width: abs(rectSize.width), height: abs(rectSize.height))
                .position(x: rectOrigin.x + rectSize.width / 2, y: rectOrigin.y + rectSize.height / 2)
                
            
            // Top-left corner circle
            DraggableCircleView(position: Binding<CGPoint>(
                get: { CGPoint(x: rectOrigin.x, y: rectOrigin.y) },
                set: { newPosition in
                    let deltaX = rectOrigin.x - newPosition.x
                    let deltaY = rectOrigin.y - newPosition.y
                    rectOrigin = newPosition
                    rectSize.width += deltaX
                    rectSize.height += deltaY
                }
            ), activeIndex: $activeIndex, currentIndex: index)
            
            // Top-right corner circle
            DraggableCircleView(position: Binding<CGPoint>(
                get: { CGPoint(x: rectOrigin.x + rectSize.width, y: rectOrigin.y) },
                set: { newPosition in
                    let deltaX = newPosition.x - (rectOrigin.x + rectSize.width)
                    let deltaY = rectOrigin.y - newPosition.y
                    rectSize.width += deltaX
                    rectSize.height += deltaY
                    rectOrigin.y = newPosition.y
                    
                    if rectSize.width < 0 {
                        rectOrigin.x += rectSize.width
                        rectSize.width = -rectSize.width
                    }
                }
            ), activeIndex: $activeIndex, currentIndex: index)
            
            // Bottom-left corner circle
            DraggableCircleView(position: Binding<CGPoint>(
                get: { CGPoint(x: rectOrigin.x, y: rectOrigin.y + rectSize.height) },
                set: { newPosition in
                    let deltaX = rectOrigin.x - newPosition.x
                    let deltaY = newPosition.y - (rectOrigin.y + rectSize.height)
                    rectSize.width += deltaX
                    rectSize.height += deltaY
                    rectOrigin.x = newPosition.x
                    
                    if rectSize.height < 0 {
                        rectOrigin.y += rectSize.height
                        rectSize.height = -rectSize.height
                    }
                }
            ), activeIndex: $activeIndex, currentIndex: index)
            
            // Bottom-right corner circle
            DraggableCircleView(position: Binding<CGPoint>(
                get: { CGPoint(x: rectOrigin.x + rectSize.width, y: rectOrigin.y + rectSize.height) },
                set: { newPosition in
                    let deltaX = newPosition.x - (rectOrigin.x + rectSize.width)
                    let deltaY = newPosition.y - (rectOrigin.y + rectSize.height)
                    rectSize.width += deltaX
                    rectSize.height += deltaY
                    
                    if rectSize.width < 0 {
                        rectOrigin.x += rectSize.width
                        rectSize.width = -rectSize.width
                    }
                    if rectSize.height < 0 {
                        rectOrigin.y += rectSize.height
                        rectSize.height = -rectSize.height
                    }
                }
            ), activeIndex: $activeIndex, currentIndex: index)
        }
        .gesture(
            TapGesture()
            .onEnded({
                activeIndex = index // 激活当前矩形
                AudioServicesPlaySystemSound(1104) // 1104 是系统默认的点击音效
            })
        )
        .cornerRadius(12)
        .frame(width: 640, height: 360)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 2)
                .stroke(.white, lineWidth: isDebugMode ? 2 : 0)
        )
        .zIndex(isActive ? 1 : 0) // 使用 zIndex 确保激活的矩形在最上层
    }
}

struct DraggableCircleView: View {
    @Binding var position: CGPoint
    @Binding var activeIndex: Int
    var currentIndex: Int
    @State var radius:CGFloat = 20
    @State private var isSoundPlayed = false
    var body: some View {
        Circle()
            .fill(activeIndex == currentIndex ? Color.blue : Color.white.opacity(0.4))
            .overlay(
                Circle()
                    .stroke(activeIndex == currentIndex ? .white : .clear, lineWidth: 2)
            )
            .frame(width: radius, height: radius)
            .hoverEffect(.highlight)
           
            .hoverEffect { effect, isactive, _ in
                //有bug，添加了这个修饰会影响颜色变化
                //effect.scaleEffect(isactive ? 1.5 : 0.8)
                effect.opacity(isactive ? 1 : 0.3)
            }
            .position(position)
            .gesture(
                DragGesture()
                    .onEnded {_ in
                        withAnimation(.easeOut(duration: 0.2), {
                            radius = 20
                        })
                        isSoundPlayed = false
                        AudioServicesPlaySystemSound(1104) // 1104 是系统默认的点击音效
                    }
                    .onChanged { value in
                        self.position = value.location
                        activeIndex = currentIndex // 激活当前矩形
                        withAnimation(.easeOut(duration: 0.2), {
                            radius = 26
                        })
                        if !isSoundPlayed {
                            AudioServicesPlaySystemSound(1104) // 1104 是系统默认的点击音效
                            isSoundPlayed = true // 设置标志，防止重复播放
                        }
                        
                    }
            )
            .gesture(
                TapGesture()
                .onEnded({
                    activeIndex = currentIndex // 激活当前矩形
                    AudioServicesPlaySystemSound(1104) // 1104 是系统默认的点击音效
                })
            )
            .transition(.opacity)
            .animation(.easeInOut, value: activeIndex)
    }
}

struct previewCanvas: View {
    var componentCount: Int = 3
    @State var activeIndex: Int = -1
    @State var rectOrigins: [CGPoint] = Array(repeating: initialPoint, count: 4)
    @State var rectSizes: [CGSize] = Array(repeating: initialSize, count: 4)
    
    var body: some View {
        BoundingboxCanvas(isDebugMode: true, componentCount: componentCount, rectOrigins: $rectOrigins, rectSizes: $rectSizes, activeIndex: $activeIndex)
    }
}

#Preview(windowStyle: .automatic) {
    previewCanvas()
}
