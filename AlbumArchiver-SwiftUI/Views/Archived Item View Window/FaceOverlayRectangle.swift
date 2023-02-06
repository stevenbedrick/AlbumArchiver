//
//  FaceOverlayRectangle.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 2/5/23.
//

import SwiftUI
import Foundation

struct FaceOverlayRectangle: View {
    
    let faceBounds : CGRect
    
    let hoverColor = Color(red: 0.0, green: 0.0, blue: 1.0, opacity: 0.25)
    let closeBoxImage = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: "Remove detected face")!

    
    var closeHandler : (() -> Void)?
    
    @State var isHovered = false
    
    var body: some View {
        Rectangle()
            .strokeBorder(Color.red, lineWidth: 2.0)
            .background(Rectangle().fill(isHovered ? hoverColor : .clear))
            .frame(width: faceBounds.width, height: faceBounds.height )
            .overlay(deleteOverlay, alignment: .topLeading)
            .onHover { over in
                isHovered = over
            }
    }
    
    @ViewBuilder private var deleteOverlay: some View {
        if isHovered {
            ZStack {
                Rectangle()
                    .fill(.white)
                Image(nsImage: closeBoxImage)
            }
            .frame(width: 20, height: 20)
            .offset(x: -10, y: -10)
            .onTapGesture {
                closeHandler?()
            }
        }
    }
    
}

extension FaceOverlayRectangle {
    
    // https://stackoverflow.com/questions/64252145/how-to-implement-custom-callback-action-in-swiftui-similar-to-onappear-function
    func onCloseButton(_ action: @escaping () -> Void) -> FaceOverlayRectangle {
        var toRet = self
        toRet.closeHandler = action
        return toRet
    }
    
}

//
//struct FaceOverlayRectangle_Previews: PreviewProvider {
//    static var previews: some View {
//        FaceOverlayRectangle()
//    }
//}
