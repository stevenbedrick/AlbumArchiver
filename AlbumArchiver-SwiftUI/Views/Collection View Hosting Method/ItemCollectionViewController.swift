//
//  ItemCollectionViewController.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/31/22.
//

import Cocoa
import SwiftUI
import Combine

class ItemCollectionViewController: NSViewController {

    @IBOutlet weak var collectionView : NSCollectionView!
    @IBOutlet weak var scrollView : FileDropScrollView!
    
     var thisPage : Page?
    
    var draggingIndexPaths: Set<IndexPath> = []
    
    // for dropping files in from Finder etc.
    let baseColor = NSColor.clear
    let dragColor = NSColor.selectedTextBackgroundColor //NSColor.systemBlue

//
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("in viewDidLoad")
//
        
        self.collectionView.register(ArchivedItemCollectionViewItemController.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("ArchivedItemCollectionViewItem"))
        self.collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        self.collectionView.wantsLayer = true
        self.scrollView.delegate = self
    }
    
    
}

// MARK: Data Source

extension ItemCollectionViewController : NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print("being asked about number of items")
        if let p = self.thisPage {
            print("items: \(p.items.count)")
            return p.items.count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ArchivedItemCollectionViewItem"), for: indexPath) as! ArchivedItemCollectionViewItemController
//        print("just called makeItem, got: \(item)")
        item.delegate = self
        
        
        // indexPath is a tuple of (section, idx)
        let targetArchivedItem = thisPage?.items[indexPath[1]]
        
        
        if let a = targetArchivedItem {
            item.representedObject = a
            item.setupItem(item: a)
        } else {
            item.textField?.stringValue = "Error!"
        }
        
        return item
    }
    
}

// MARK: Collection View Delegate

extension ItemCollectionViewController : NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        let pasteboardItem = NSPasteboardItem()
        
        // put the index that we are dragging into the pasteboard
        pasteboardItem.setString("\(indexPath[1])", forType: NSPasteboard.PasteboardType.string)
        
        print(pasteboardItem)
        return pasteboardItem
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        return .move
    }
    
    // About to drag
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
//        print("dragging \(indexPaths)")
        draggingIndexPaths = indexPaths
    }
    
    // End of drag
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        draggingIndexPaths = []
    }
    
    // actually handle drop
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        
        for fromIndexPath in draggingIndexPaths {
            
            // actually remove from list of items
            if let p = thisPage {
                let draggedItem = p.items.remove(at: fromIndexPath.item)
                
                NSAnimationContext.current.duration = 0.5;
                self.collectionView.animator().deleteItems(at: [fromIndexPath]);
                
                // figure out new index
                let newIndex = (indexPath.item<=fromIndexPath.item) ? indexPath.item : (indexPath.item-1)
                
                // put back in at the new index
                p.items.insert(draggedItem, at: newIndex)
                
                self.collectionView.animator().insertItems(at: [IndexPath(item: newIndex, section: 0)])
                
            }
            
        }
        
        return true
        
        
    }

    
}


class FileDropScrollView : NSScrollView {
    
    // drag and drop stuff
    let supportedDropTypes : [NSPasteboard.PasteboardType] = [ .fileURL ]
    
    var delegate : FileDragDropDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.registerForDraggedTypes(supportedDropTypes)
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        self.delegate?.draggingEntered(sender)
        
        let canRead = sender.draggingPasteboard.canReadObject(forClasses: [NSURL.self])
        
        
        if canRead {
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.delegate?.draggingExited(sender)
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.delegate?.draggingEnded(sender)
    }
    
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        guard let droppedObjects = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self])
        else {
            return false
        }
        
        droppedObjects.forEach { obj in
            if let url = obj as? NSURL {
                self.delegate?.droppedFile(withURL: url)
            }
        }
        
        return true
    }
}

extension ItemCollectionViewController : FileDragDropDelegate {
    
    func droppedFile(withURL url: NSURL) {
        
        // try adding an item to my page
        DispatchQueue.global(qos: .userInitiated).async {
            
            let rawIm = NSImage(byReferencing: url as URL)
            if rawIm.isValid {
                
                // Make sure this happens on the main UI thread, or else things
                // blow up badly
                DispatchQueue.main.async {
                    
                    // set up a new item
                    // first, figure out file name
                    let newItem : ArchivedItem
                    if let fileName = url.lastPathComponent {
                        newItem = ArchivedItem(withName: fileName, withImage: rawIm)
                    } else {
                        newItem = ArchivedItem(withName: "New Item", withImage: rawIm)
                    }
                    
                    self.thisPage?.addItem(someItem: newItem)
                }
            }  else {
                print("Could not load image from \(url)")
            }
        }
        
        
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) {
        self.collectionView.backgroundColors = [dragColor]
    }
    
    func draggingExited(_ sender: NSDraggingInfo?) {
        self.collectionView.backgroundColors = [baseColor]
    }
    
    func draggingEnded(_ sender: NSDraggingInfo) {
        self.collectionView.backgroundColors = [baseColor]
    }
    
}

extension ItemCollectionViewController : ArchivedItemCollectionViewItemDelegate {
    func updateAttachmentForItemAtIndexPath(path: IndexPath, withContentsOfUrl url: NSURL) {
        
        if let targetArchivedItem = thisPage?.items[path[1]] {
            print("Handling an item update for \(targetArchivedItem)")
            targetArchivedItem.attachItem(fromUrl: url as URL)
            self.collectionView.reloadData()
        }
        
    }
    
    func doubleClickAtIndexPath(path: IndexPath) {
        if let targetArchivedItem = thisPage?.items[path[1]] {
            print("handle double click for \(targetArchivedItem.name)")
        }
    }
    
    
}
