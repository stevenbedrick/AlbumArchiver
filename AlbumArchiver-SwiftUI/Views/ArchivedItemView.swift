//
//  ArchivedItemView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/7/22.
//

import SwiftUI

struct ArchivedItemView: View {
    
    @ObservedObject var item : ArchivedItem
    
    @State var active = false
    
    static let initialPlaceholderImage = NSImage(systemSymbolName: "photo", accessibilityDescription: "Drag image file here")!
    
    
    init(withItem item: ArchivedItem) {
        self.item = item
    }

    
    var body: some View {
        
        let dropDelegate = ItemDropDelegate(active: $active, myItem: item)
        
        VStack {
            Spacer()
            HStack {
                Spacer()
//                ScrollView {
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
                                        }
                                
                                
                            } else {
                                Image(nsImage: ArchivedItemView.initialPlaceholderImage)
                            }
                            
                            
                        }.background(active ? Color.gray : Color.clear)
                            .onDrop(of: ["public.file-url"], delegate: dropDelegate)
                            
                        
                        Divider()
                        
                        VStack {
                            Text("Notes:").frame(maxWidth: .infinity, alignment: .leading)
                            TextEditor(text: $item.notes)
                        }
                        
                        
//                    }
                }
                
                Spacer()
            }
            Spacer()
        }.frame(minWidth: 420, minHeight: 512.0)
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
