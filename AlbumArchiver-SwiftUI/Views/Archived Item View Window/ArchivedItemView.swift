//
//  ArchivedItemView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/7/22.
//

import SwiftUI
import Vision

struct ArchivedItemView: View {
    
    @Environment(\.undoManager) var undoManager
    
    @ObservedObject var item : ArchivedItem
    
    @State var active = false
    
//    @State var faces : [VNFaceObservation] = []
    
    static let initialPlaceholderImage = NSImage(systemSymbolName: "photo", accessibilityDescription: "Drag image file here")!
    
    
    init(withItem item: ArchivedItem) {
        self.item = item
    }

    
    var body: some View {
        
        let dropDelegate = ItemDropDelegate(active: $active, myItem: item)
        
        VStack {
            Form {
                TextField("Title:", text: $item.name)
                
                GroupBox {
                    if let i = item.image {
                        
                        self.imageWithFaceOverlay(someImage: i)
                        
                        
                    } else {
                        Image(nsImage: ArchivedItemView.initialPlaceholderImage)
                    }
                }.background(active ? Color.gray : Color.clear)
                    .onDrop(of: ["public.file-url"], delegate: dropDelegate)
                
                Divider()
                
                Text("Notes:").frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $item.notes)
            } // Form
                
        }.padding()
            .frame(minWidth: 512, minHeight: 600) // VStack
        
        
    }
    
    @discardableResult
    func openInWindow(title: String, sender: Any) -> NSWindow {
        let controller = NSHostingController(rootView: self)
        let win = NSWindow(contentViewController: controller)
        win.contentViewController = controller
        win.title = title
        win.makeKeyAndOrderFront(sender)
        return win
    }
    
    func imageWithFaceOverlay(someImage i : NSImage) -> some View {
        return Image(nsImage: i).resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 380, height: 400)
            .onTapGesture(count: 2) {
                if let u = item.imageFileURL {
                    NSWorkspace.shared.open(u)
                }
            }.overlay {
                GeometryReader { (geometry: GeometryProxy) in
                    
                    /*
                     
                     Draw Rectangles over our image for each face that we've found.
                     
                     This is slightly tricky: our face bounding boxes are in a coordinate system relative to the image
                     itself, and we need to draw them in a totally different coordinate system: that of the Image View
                     displaying our Item's image, which itself is containined in some other View.
                     
                     As an additional complication, our image is scaled to fit, which means that (depending on its
                     orientation, portrait vs. landscape) its boundaries are offset from either the sides or the top/bottom
                     of the Image.
                     
                     So we need to do multiple transformations:
                     
                     1. Flip y-coordinates, since SwiftUI's coordinate system is flipped relative to the one used by NSImage etc.
                     2. Handle translation in X (if portrait) or Y (if landscape) due to the scale-to-fit
                     3. Scale from the image's dimensions to those of our containing View
                     
                     This is a little convoluted!
                     
                     */
                    
                    // compute a transform matrix
                    let imViewHeight = geometry.size.height
                    let imViewWidth = geometry.size.width
                    let origImageHeight = i.size.height
                    let origImageWidth = i.size.width
                    
                    // Are we in portrait or landscape mode- both for the original image,
                    // and then however it's endnig up being scaled/fit into the view in question
                    let imViewAspectRatio = imViewWidth / imViewHeight
                    let origImageAspectRatio = origImageWidth / origImageHeight
                    
                    let scaleFactor = (imViewAspectRatio > origImageAspectRatio) ? imViewHeight / origImageHeight : imViewWidth / origImageWidth
                    
                    let scaledImageWidth = origImageWidth  * scaleFactor
                    let scaledImageHeight = origImageHeight * scaleFactor
                    
                    // the actual corners of the image
                    let adjXVal = (imViewWidth - scaledImageWidth) / 2.0
                    let adjYVal = (imViewHeight - scaledImageHeight) / 2.0
                    
                    
                    // Useful refs:
                    // https://stackoverflow.com/questions/73397910/swift-ios-vision-framework-text-recognition-and-rectangles/73399681#73399681
                    // https://github.com/Willjay90/AppleFaceDetection
                    
                    // Handle landscape orientation; need to adjust y-axis flipping by adjYVal somehow, since our image view is scaling "to fit"
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: adjXVal, y: -scaledImageHeight - adjYVal)

                    let scale = CGAffineTransform.identity.scaledBy(x: scaledImageWidth, y: scaledImageHeight)

                    
                    ForEach(item.faces, id: \.self) {thisFace in
                        
                        let facebounds = thisFace.boundingBox.applying(scale).applying(transform)
                        
                        FaceOverlayRectangle(faceBounds: facebounds)
                            .onCloseButton {
                                item.removeDetectedFace(faceToRemove: thisFace, withUndoManager: undoManager)
                                
                            }
                            .offset(x: facebounds.origin.x, y: facebounds.origin.y)
                    }
                }
            }
    }
    
}


struct ItemDropDelegate : DropDelegate {
    
    @Binding var active : Bool
    var myItem : ArchivedItem
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: ["public.file-url"])
        
    }
    
    func dropEntered(info: DropInfo) {
        active = true
    }
    
    func performDrop(info: DropInfo) -> Bool {

        
        if let i = info.itemProviders(for: ["public.file-url"]).first {
            i.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, err) in
                if let urlData = urlData as? Data {
                    let asUrl = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                    
                    myItem.attachItem(fromUrl: asUrl)
                    
                
                        
                    
                }
            }
        }
        
        return true
    }
    
    func dropExited(info: DropInfo) {
        active = false
    }
    
    
    
}
