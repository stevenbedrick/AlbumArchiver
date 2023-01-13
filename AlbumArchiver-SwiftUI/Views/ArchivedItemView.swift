//
//  ArchivedItemView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/7/22.
//

import SwiftUI
import Vision

struct ArchivedItemView: View {
    
    @ObservedObject var item : ArchivedItem
    
    @State var active = false
    
    @State var faces : [VNFaceObservation] = []
    
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
                        
                        Image(nsImage: i).resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 380, height: 400)
                            .onTapGesture(count: 2) {
                                print("Double-clicked")
                                if let u = item.imageFileURL {
                                    print("Will try and open \(u)")
                                    NSWorkspace.shared.open(u)
                                } else {
                                    print("no url to open")
                                }
                            }.overlay {
                                GeometryReader { (geometry: GeometryProxy) in
                                    
                                    // compute a transform matrix
                                    let imViewHeight = geometry.size.height
                                    let imViewWidth = geometry.size.width
                                    let origImageHeight = i.size.height
                                    let origImageWidth = i.size.width
                                    
                                    let imViewAspectRatio = imViewWidth / imViewHeight
                                    let origImageAspectRatio = origImageWidth / origImageHeight
                                    
                                    let scaleFactor = (imViewAspectRatio > origImageAspectRatio) ? imViewHeight / origImageHeight : imViewWidth / origImageWidth
                                    
                                    let scaledImageWidth = origImageWidth  * scaleFactor
                                    let scaledImageHeight = origImageHeight * scaleFactor
                                    
                                    // the actual corners of the image
                                    let adjXVal = (imViewWidth - scaledImageWidth) / 2.0
                                    let adjYVal = (imViewHeight - scaledImageHeight) / 2.0
                                    
                                    
                                    
                                    // https://github.com/Willjay90/AppleFaceDetection
                                    // TODO: handle landscape orientation; need to adjust y-axis flipping by adjYVal somehow
                                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: adjXVal, y: -scaledImageHeight)

                                    let scale = CGAffineTransform.identity.scaledBy(x: scaledImageWidth, y: scaledImageHeight)

                                    
                                    ForEach(self.faces, id: \.self) {thisFace in
                                        
                                        let facebounds = thisFace.boundingBox.applying(scale).applying(transform)
                                        
                                        Rectangle().path(in: facebounds).stroke(Color.red, lineWidth: 2.0)

                                    }
                                }
                            }
                        
                        
                    } else {
                        Image(nsImage: ArchivedItemView.initialPlaceholderImage)
                    }
                }.background(active ? Color.gray : Color.clear)
                    .onDrop(of: ["public.file-url"], delegate: dropDelegate)
                
                Divider()
                
                Text("Notes:").frame(maxWidth: .infinity, alignment: .leading)
                TextEditor(text: $item.notes)
            } // Form
            
            Spacer()
            HStack {
                Button("Click") {
                    if let f = FaceDetectionManager.facesInItem(item: item) {
                        faces = f
                    }
                }
                Spacer()
                Text("Faces: \(faces.count)")
            }
                
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
