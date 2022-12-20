//
//  PageView.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import SwiftUI
import Cocoa

struct PageView: View {
    
    @State var active = false

    @ObservedObject var thisPage: Page
    
    var gridLayout : [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        
        let dropDelegate = PageDropDelegate(active: $active, myPage: thisPage)
        
        VStack {
            HStack {
                Text("Page:")
                TextField("New Page Number", text: $thisPage.number)
            }
            Text("Items:")
            
            // Option 1: List
//            List(thisPage.items) { anItem in
            
            // Option 2: LazyVGrid in a ScrollView
            ZStack { // se we have something to fill the container
                ScrollView {
                    VStack {
                        LazyVGrid(columns: gridLayout) {
                            ForEach(thisPage.items) { anItem in
                                ArchivedItemView(item: anItem)
                            }
                        }
                    }
                }
            }.background(active ? Color.red : Color.blue)
                .frame(maxHeight: .infinity)
                .onDrop(of: ["public.file-url"], delegate: dropDelegate)
            
            // Option 3: Table
//            Table(thisPage.items) {
//                TableColumn("Name", value: \.name)
//                TableColumn("Content") { item in
//                    if let im = item.image {
//                        Image(nsImage: im)
//                    } else {
//                        Image(nsImage: ArchivedItemView.initialPlaceholderImage)
//                    }
//                }
//                TableColumn("CustomView") { item in
//                    ArchivedItemView(item: item)
//                }
//            }
            
            

            HStack {
                Button("New Item") {
                    thisPage.addItem()
                }.padding()
                Spacer()
            }
        }
    }
}

struct PageDropDelegate : DropDelegate {
    
    
    @Binding var active : Bool
    var myPage : Page
    
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
                    let asUrl = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil)
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        let rawIm = NSImage(byReferencing: asUrl as URL)
                        if rawIm.isValid {
                            
                            DispatchQueue.main.async {
                                
                                // set up a new item
                                // first, figure out file name
                                let newItem : ArchivedItem
                                if let fileName = asUrl.lastPathComponent {
                                    newItem = ArchivedItem(withName: fileName, withImage: rawIm)
                                } else {
                                    newItem = ArchivedItem(withName: "New Item", withImage: rawIm)
                                }
                                
                                myPage.addItem(someItem: newItem)
                            }
                        }  else {
                                print("Could not load image from \(asUrl)")
                        }
                            
                        
                        
                    }
                    
                    
                    
                }
            }
        }
        
        return true
    }
    
    func dropExited(info: DropInfo) {
        active = false
    }

    
}
