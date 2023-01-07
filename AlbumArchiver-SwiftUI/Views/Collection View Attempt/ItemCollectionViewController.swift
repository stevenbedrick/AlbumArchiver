//
//  ItemCollectionViewController.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/31/22.
//

import Cocoa

class ItemCollectionViewController: NSViewController {

    @IBOutlet weak var collectionView : NSCollectionView!
    
    var thisPage : Page?
    
    var draggingIndexPaths: Set<IndexPath> = []

//
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("in viewDidLoad")
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(ArchivedItemCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("ArchivedItemCollectionViewItem"))
        self.collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
    }
    
}

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
        
        
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ArchivedItemCollectionViewItem"), for: indexPath) as! ArchivedItemCollectionViewItem
        
        
        // indexPath is a tuple of (section, idx)
        let targetArchivedItem = thisPage?.items[indexPath[1]]
        
        if let a = targetArchivedItem {
            item.setupItem(item: a)
        } else {
            item.textField?.stringValue = "Error!"
        }
        
        return item
    }
    
}

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
        print("dragging \(indexPaths)")
        draggingIndexPaths = indexPaths
    }
    
    // End of drag
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        draggingIndexPaths = []
    }
    
    // actually handle drop
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        
        
        return true
        
        
    }

    
}
