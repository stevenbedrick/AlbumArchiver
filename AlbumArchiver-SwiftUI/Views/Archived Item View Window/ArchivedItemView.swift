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
    
    @State var startPoint : CGPoint? = nil
    @State var stopPoint : CGPoint? = nil
    
    @State var currentManualSelectionRect : CGRect? = nil
    
    @State var personLinkPopoverShowing = false
    
//    @State var faces : [VNFaceObservation] = []
    
    static let initialPlaceholderImage = NSImage(systemSymbolName: "photo", accessibilityDescription: "Drag image file here")!
    
    
    init(withItem item: ArchivedItem) {
        self.item = item
    }

    func makeSelectionRect(start: CGPoint?, stop: CGPoint?, boundedIn: CGRect? = nil ) -> CGRect? {
        if let origin = start, let endPoint = stop {
            
            guard let bbox = boundedIn else {
                
                return sensibleBoundingBoxFromDragCoords(start: origin, stop: endPoint)
            }
            
            // problem: endPoint might have gone "off the edge of the map"
            
            var adjEndPoint = endPoint
            
            if endPoint.x < bbox.origin.x {
                // we've gone too far to the left:
                adjEndPoint.x = bbox.origin.x
            }
            
            if endPoint.x > (bbox.origin.x + bbox.width) {
                // we've gone too far to the right
                adjEndPoint.x = bbox.origin.x + bbox.width
            }
            
            if endPoint.y < bbox.origin.y {
                // too far up
                adjEndPoint.y = bbox.origin.y
            }
            
            if endPoint.y > (bbox.origin.y + bbox.height) {
                adjEndPoint.y = bbox.origin.y + bbox.height
            }
            
            let toRet = sensibleBoundingBoxFromDragCoords(start: origin, stop: adjEndPoint)
//            currentManualSelectionRect = toRet // save for later
            return toRet
            
        }
        return nil
    }
    
    var body: some View {
        
        let dropDelegate = ItemDropDelegate(active: $active, myItem: item)
        
        VStack {
            Form {
                TextField("Title:", text: $item.name)
                
                GroupBox {
                    if let i = item.image {
                            self.imageWithFaceOverlay(someImage: i)
                                .overlay(alignment: .topLeading) {
                                    GeometryReader { (geometry: GeometryProxy) in
                                        
                                        let imageGeometry = ImageViewGeometryProps(withImage: i, inViewGeometry: geometry)
                                        
                                        // Do we have an active selection event happening?
                                        if let origin = startPoint, let endPoint = stopPoint {
                                            let myRect = makeSelectionRect(start: origin, stop: endPoint, boundedIn: imageGeometry.imageBoundingBoxInView())!
                                            Rectangle().path(in: myRect).stroke(Color.red, lineWidth: 2.0)
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
                        
                        let projectionGeometry = ImageViewGeometryProps(withImage: i, inViewGeometry: geometry)
                        
                        ForEach(item.faces, id: \.self) {thisFace in
                            
                            let facebounds = thisFace.boundingBox.applying(projectionGeometry.scale).applying(projectionGeometry.transform)
                            
                            FaceOverlayRectangle(faceBounds: facebounds)
                                .onCloseButton {
                                    item.removeDetectedFace(faceToRemove: thisFace, withUndoManager: undoManager)
                                }
                                .popover(isPresented: $personLinkPopoverShowing, arrowEdge: .bottom) {
                                    PersonPickerPopupView(thisItem: self.item, faceObs: thisFace).environmentObject(item.page.album.library)
                                }
                                .onTapGesture {
                                    personLinkPopoverShowing = !personLinkPopoverShowing
                                }
                                .offset(x: facebounds.origin.x, y: facebounds.origin.y)
                                
                        }
                        
                    } // end geometry reader
                } // end overlay
                .gesture(
                        DragGesture().onChanged { gest in
                            startPoint = gest.startLocation
                            stopPoint = gest.location
                        }
                        .onEnded { gest in
                            saveManualFace()
                            startPoint = nil
                            stopPoint = nil
                        }
                        
                )
        
    }
    
    func saveManualFace() {
        

        return
        // at this point, faceRect's coordinates are in the same space as the view. We need to turn them into normalized image coordinates- basically doing the reverse process that we do to draw the boxes from FaceObservations
        
        
        
    }
    
    func sensibleBoundingBoxFromDragCoords(start: CGPoint, stop: CGPoint) -> CGRect {
        // The direction of the drag that got us these points (top-left to bottom-right vs. top-right to bottom-left etc.) will affect which one makes sense to use as the origin for our bounding box.
        //
        // If we don't figure out which point to use as the origin, we'll end up with negative widths etc.
        
        let pointA = start
        let pointB = stop
        let pointC = CGPoint(x: start.x, y: stop.y)
        let pointD = CGPoint(x: stop.x, y: start.y)
        
        let pointsToSort = [pointA, pointB, pointC, pointD]
        
        let sortedPoints = pointsToSort.sorted { a, b in
            
            if a.y != b.y {
                return a.y < b.y // sort by Y
            } else {
                return a.x < b.x // then by X
            }
            
        }
        
        // We know exactly how many points will be in the array so this is OK
        let originToUse = sortedPoints.first!
        let endPointToUse = sortedPoints.last!
        
        
        let height = endPointToUse.y - originToUse.y
        let width = endPointToUse.x - originToUse.x
        return CGRect(origin: originToUse, size: CGSize(width: width, height: height))

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


struct ImageViewGeometryProps {
    
    let imViewSize : CGSize
    let origImageSize : CGSize
    let imViewAspectRatio : CGFloat
    let origImageAspectRatio : CGFloat
    let scaleFactor : CGFloat
    let scaledImageSize : CGSize
    let adjXVal : CGFloat
    let adjYVal : CGFloat
    let transform : CGAffineTransform
    let scale :CGAffineTransform
    
    init(withImage anImage : NSImage, inViewGeometry geometry : GeometryProxy) {
        
        /*
         Figure out all the bits and pieces we'll need in order to map View coordinates into NSImage coordinates, etc., for drawing face bounding boxes.
         
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
        imViewSize = geometry.size
        origImageSize = anImage.size
        
        let imViewHeight = imViewSize.height
        let imViewWidth = imViewSize.width
        let origImageHeight = origImageSize.height
        let origImageWidth = origImageSize.width
        
        // Are we in portrait or landscape mode- both for the original image,
        // and then however it's endnig up being scaled/fit into the view in question
        imViewAspectRatio = imViewWidth / imViewHeight
        origImageAspectRatio = origImageWidth / origImageHeight
        
        scaleFactor = (imViewAspectRatio > origImageAspectRatio) ? imViewHeight / origImageHeight : imViewWidth / origImageWidth
        
        let scaledImageWidth = origImageWidth  * scaleFactor
        let scaledImageHeight = origImageHeight * scaleFactor

        scaledImageSize = CGSize(width: scaledImageWidth, height: scaledImageHeight)

        // the actual corners of the image as it is currently sitting inside the view, i.e.
        // after adjusting for whatever blank space is around the image because it's been
        // scaled to fit. In the view's coordinate system.
        adjXVal = (imViewWidth - scaledImageWidth) / 2.0
        adjYVal = (imViewHeight - scaledImageHeight) / 2.0

        // Useful refs:
        // https://stackoverflow.com/questions/73397910/swift-ios-vision-framework-text-recognition-and-rectangles/73399681#73399681
        // https://github.com/Willjay90/AppleFaceDetection
        
        // Handle landscape orientation; need to adjust y-axis flipping by adjYVal somehow, since our image view is scaling "to fit"
        transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: adjXVal, y: -scaledImageHeight - adjYVal)

        scale = CGAffineTransform.identity.scaledBy(x: scaledImageWidth, y: scaledImageHeight)

        
    }
    
    func imageBoundingBoxInView() -> CGRect {
        return CGRect(origin: CGPoint(x: adjXVal, y: adjYVal), size: scaledImageSize)
    }
    
}
