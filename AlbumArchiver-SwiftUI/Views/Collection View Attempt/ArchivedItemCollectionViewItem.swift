//
//  ArchivedItemCollectionViewItem.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/31/22.
//

import Cocoa
import SwiftUI


class ArchivedItemCollectionViewItem: NSCollectionViewItem {


    // we get a free textField and imageView from NSCollectionViewItem
    
    var myItem : ArchivedItem?
    
    let initialPlaceholderImage = NSImage(systemSymbolName: "photo", accessibilityDescription: "Drag image file here")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        
    }
    
    func setupItem(item: ArchivedItem) {
        self.myItem = item
        if let a = myItem {
            self.textField?.stringValue = a.name
            if let i = a.image {
                self.imageView?.image = i
            } else {
                self.imageView?.image = initialPlaceholderImage
            }
            
        }
    }
    
}
