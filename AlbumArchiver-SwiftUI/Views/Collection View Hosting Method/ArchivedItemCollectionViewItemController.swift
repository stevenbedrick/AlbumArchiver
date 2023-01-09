//
//  ArchivedItemCollectionViewItem.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/31/22.
//

import Cocoa
import SwiftUI
import Combine

protocol ArchivedItemCollectionViewItemDelegate {
    func updateAttachmentForItemAtIndexPath(path: IndexPath, withContentsOfUrl url: NSURL)
    func doubleClickAtIndexPath(path: IndexPath)
}

protocol FileDragDropDelegate {
    func droppedFile(withURL url: NSURL)
    func draggingEntered(_ sender: NSDraggingInfo)
    func draggingExited(_ sender: NSDraggingInfo?)
    func draggingEnded(_ sender: NSDraggingInfo)
}

class ArchivedItemCollectionViewItemController: NSCollectionViewItem {

    // we get a free textField and imageView from NSCollectionViewItem
    
    var imageWatcher : AnyCancellable?
    var nameWatcher : AnyCancellable?
    
    var myItem : ArchivedItem?
    
    let initialPlaceholderImage = NSImage(systemSymbolName: "photo", accessibilityDescription: "Drag image file here")!
    
    var delegate : ArchivedItemCollectionViewItemDelegate?
    
    @IBOutlet weak var box: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let v = self.view as? ArchivedItemCollectionViewItemView {
            v.delegate = self
        }
        
    }
    
    func setupItem(item: ArchivedItem) {
        
//        print("In setupItem, I have a delegate: \(self.delegate)")
        
        self.myItem = item
        
        imageWatcher = myItem?.$image.sink(receiveValue: { anImage in
            self.imageView?.image = anImage
        })
        
        nameWatcher = myItem?.$name.sink(receiveValue: { newName in
            self.textField?.stringValue = newName
        })


        if let a = myItem {
            self.textField?.stringValue = a.name
            if let i = a.image {
                self.imageView?.image = i
            } else {
                self.imageView?.image = initialPlaceholderImage
            }
            
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.imageWatcher?.cancel()
        self.nameWatcher?.cancel()
        
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        
        let indexPath = self.collectionView?.indexPath(for: self)
        
//        print("Click, I am at index path: \(indexPath), my item is: \(myItem?.name)")
//
//        print("\tRepresented object: \(self.representedObject)")
//        print("\tdelegate: \(self.delegate)")
//        print("\tI am: \(self)")
        if event.clickCount == 2 {
//            print("Tryign to get path")
            if let myPath = self.collectionView?.indexPath(for: self) {
//                print("forwarding to delegate: \(String(describing: self.delegate))")
                self.delegate?.doubleClickAtIndexPath(path: myPath)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
//        print("In prepareForReUse, I am \(self), delegate is: \(self.delegate)")
        
//        print("Trying to cancel watchers")
        if let iw = imageWatcher {
//            print("Cancelling imageWatcher")
            iw.cancel()
        } else {
//            print("No imageWatcher to cancel")
        }
        
        if let nw = nameWatcher {
//            print("Cancelling nameWatcher")
            nw.cancel()
        } else {
//            print("No nameWatcher to cancel")
        }
        
        if let i = myItem {
            setupItem(item: i)
        } else {
//            print("I don't have an item right now")
        }
    }
    
}




extension ArchivedItemCollectionViewItemController : FileDragDropDelegate {
    
    // we don't actually care about these events
    func draggingEntered(_ sender: NSDraggingInfo) {
        return
    }
    
    func draggingExited(_ sender: NSDraggingInfo?) {
        return
    }
    
    func draggingEnded(_ sender: NSDraggingInfo) {
        return
    }
    
    func droppedFile(withURL url: NSURL) {
        
        // figure out where we are:
        if let myPath = self.collectionView?.indexPath(for: self) {
            
            self.delegate?.updateAttachmentForItemAtIndexPath(path: myPath, withContentsOfUrl: url)
        } else {
            print("In delegate, could not figure out my own path?")
        }
        
//
//        if let i = myItem {
//            print("dropped, myItem is: \(myItem)")
//            i.attachItem(fromUrl: url as URL)
//        }
    }
    
    
    
}
