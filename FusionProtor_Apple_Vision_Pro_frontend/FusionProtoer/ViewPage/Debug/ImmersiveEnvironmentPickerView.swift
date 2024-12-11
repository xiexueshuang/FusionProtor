////
////  ImmersiveEnvironmentPickerView.swift
////  FusionProtoer
////
////  Created by 蒋招衢 on 2024/8/15.
////
//
//import SwiftUI
//
///// Describes the environment state.
//enum EnvironmentStateType: String {
//    case light
//    case dark
//    case none
//
//    var displayName: String {
//        return switch self {
//        case .light:
//            String(localized: "Light", comment: "Label for Light environment")
//        case .dark:
//            String(localized: "Dark", comment: "Label for Dark environment")
//        case .none:
//            String(localized: "None", comment: "Label for environment that is neither dark nor light")
//        }
//    }
//
//    var name: String {
//        [self.rawValue.capitalized, "State"].joined()
//    }
//}
//
//class ImmersiveEnvironment: ObservableObject {
//    @Published var currentState: EnvironmentStateType = .light
//    
//    func requestEnvironmentState(_ state: EnvironmentStateType) {
//        currentState = state
//    }
//    
//    func loadEnvironment() {
//        // Logic to load the environment based on the currentState
//        print("Loading \(currentState.displayName) environment")
//    }
//}
//
//
///// A view that populates the ImmersiveEnvironmentPicker in an undocked AVPlayerViewController.
//struct ImmersiveEnvironmentPickerView: View {
//    
//    var body: some View {
//        StudioButton(state: .dark)
//        StudioButton(state: .light)
//    }
//}
//
///// A view for the buttons that appear in the environment picker menu.
//private struct StudioButton: View {
//    // @Environment(ImmersiveEnvironment.self) private var immersiveEnvironment
//    @EnvironmentObject var immersiveEnvironment: ImmersiveEnvironment
//    var state: EnvironmentStateType
//
//    var body: some View {
//        Button {
//            immersiveEnvironment.requestEnvironmentState(state)
//            immersiveEnvironment.loadEnvironment()
//        } label: {
//            Label {
//                Text("Studio", comment: "Show Studio environment")
//            } icon: {
//                Image(["studio_thumbnail", state.displayName.lowercased()].joined(separator: "_"))
//            }
//            Text(state.displayName)
//        }
//    }
//}
//
//#Preview(windowStyle: .automatic) {
////    @Previewable @Environment(\.openImmersiveSpace) var openImmersiveSpace
////    WelcomeView()
////        .immersiveEnvironmentPicker {
////            Button("Chalet", systemImage: "fireplace") {
////                Task {
////                    await openImmersiveSpace(id: "Chalet")
////                }
////            }
////        }
//    
//    VStack{
//        Text("hello")
//    }
//        .immersiveEnvironmentPicker {
//            ImmersiveEnvironmentPickerView()
//        }
//}
