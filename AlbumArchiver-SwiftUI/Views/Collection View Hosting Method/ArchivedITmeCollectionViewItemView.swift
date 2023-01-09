//
//  ArchivedITmeCollectionViewItemView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 1/8/23.
//

import Foundation
import Cocoa

class ArchivedItemCollectionViewItemView : NSView {
    // drag and drop stuff
    let supportedDropTypes : [NSPasteboard.PasteboardType] = [ .fileURL ]
    
    
    // The class we inform when a file has been dropped- in this case, an NSCollectionViewItem subclass
    var delegate : FileDragDropDelegate?
    
    let baseColor = NSColor(calibratedRed: 240/255, green: 240/255, blue: 240/255, alpha: 1.0).cgColor
    let dragColor = NSColor.lightGray.cgColor
    
    @IBOutlet weak var box : NSBox!
    
    @IBOutlet weak var imView : NSImageView! {
        didSet {
            // if we don't do this, the NSImageView will mess with drag/drop
            imView.unregisterDraggedTypes()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerForDraggedTypes(supportedDropTypes)
        // Do view setup here.
        self.wantsLayer = true
        self.layer?.backgroundColor = baseColor
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
//        print("Collection Item View - Dragging entered!")
        self.delegate?.draggingEntered(sender)
        
        let canRead = sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self])
        
        if canRead {
//            print("I can read this type!")
            self.layer?.backgroundColor = dragColor
            return .copy
        } else {
//            print("I cannot read this type!")
            return NSDragOperation()
        }
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
//        print("Collection Item View - Dragging exited")
        self.delegate?.draggingExited(sender)
        self.layer?.backgroundColor = baseColor
        
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
//        print("Collection Item View - Dragging ended!")
        self.delegate?.draggingEnded(sender)
        self.layer?.backgroundColor = baseColor
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
//        print("Collection Item View - performing drag!")
        
        guard let droppedObjects = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self])
        else {
            return false
        }
        
        droppedObjects.forEach { obj in
            if let url = obj as? NSURL {
//                print("Got a NSURL: \(url)")
//                print("Calling delegate if exists")
                self.delegate?.droppedFile(withURL: url)
            }
        }
        
        return true
    }

}
