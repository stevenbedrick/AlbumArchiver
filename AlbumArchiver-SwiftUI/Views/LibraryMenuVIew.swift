//
//  LibraryMenuVIew.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import Foundation
import SwiftUI
import Cocoa
import Combine

struct LibraryMenuView : View {
    
    @ObservedObject var library : Library
    
    
    var menu : [MenuEntry] = []
    
    
    init(withLibrary: Library) {
        library = withLibrary
        menu = makeMenu()
        
    }
    
    var body: some View {

        
        VStack {
            
            List {
                Section(header: Text("Albums")) {
                    
                    OutlineGroup(menu, id: \.value, children: \.children) { item in
                        switch item.value {
                        case .album(let a):
                            AlbumMenuItemVIew(item: a)
                        case .page(let p):
                            PageMenuItemView(item: p)
                        }

                    }
                    
                }
                
                Divider()
                
                PersonMenuItemView(library: library)
                

            }.listStyle(.sidebar)
            
//            List(menu, id: \.value, children: \.children) { item in
//
//                switch item.value {
//                case .album(let a):
//                    AlbumMenuItemVIew(item: a)
//                case .page(let p):
//                    PageMenuItemView(item: p)
//                }
//
//            }.listStyle(.sidebar)
            
            
        }
            

    }
    
    
    func makeMenu() -> [MenuEntry] {
        var toRet : [MenuEntry] = []
        print("in makeMenu, album count: \(self.library.albums.count)")
        
        
        for a in self.library.albums {
            print("Processing album \(a.name)")
            var thisEntry = MenuEntry(value: .album(a))
            if a.pages.count > 0 {
                thisEntry.children = []
            }
            
            for p in a.pages {
                print("Processing page \(p.number)")
                thisEntry.children?.append(MenuEntry(value: .page(p)))
            }
            
            toRet.append(thisEntry)
        }
        
        
        
        return toRet
    }
}


struct MenuEntry : Hashable, Identifiable {
    
    let id = UUID()
    
    enum MenuEntryContent : Hashable {
        
        case album(Album)
        case page(Page)
        
//        func hash(into hasher: inout Hasher) {
//            switch self {
//            case .album(let a):
//                hasher.combine(a)
//            case .page(let p):
//                hasher.combine(p)
//            }
//        }

        
    }

    
    var value: MenuEntryContent
    var children: [MenuEntry]? = nil
    
    
}


struct AlbumMenuItemVIew : View {
    @ObservedObject var item: Album
    
    static let albumImage = NSImage.init(systemSymbolName: "book", accessibilityDescription: "Photo album in catalog")!

    var body : some View {
        
            
            NavigationLink(destination: AlbumView(thisAlbum: item)) {
                HStack {
                    Image(nsImage: AlbumMenuItemVIew.albumImage)
                    Text(item.name)
                }
            }

    }
    
}

struct PageMenuItemView : View {
    @ObservedObject var item : Page
    
    static let pageImage = NSImage.init(systemSymbolName: "doc.richtext", accessibilityDescription: "Page in an album")!

    var body : some View {
            NavigationLink(destination: PageView(thisPage: item)) {
                HStack{
                    Image(nsImage: PageMenuItemView.pageImage)
                    Text(item.number)
                }
            }
    }
    
    
}

struct PersonMenuItemView : View {
    static let personImage = NSImage.init(systemSymbolName: "person.fill", accessibilityDescription: "People in library")!
    
    @ObservedObject var library : Library
    
    var body : some View {
        NavigationLink(destination: PersonListView(library: library)) {
            HStack{
                Image(nsImage: PersonMenuItemView.personImage)
                Text("People")
            }
        }

    }
}


