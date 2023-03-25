//
//  Album.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/4/22.
//

import Foundation
import SwiftUI
import Combine

public class Album : Identifiable, ObservableObject, Equatable, Hashable {
    public static func == (lhs: Album, rhs: Album) -> Bool {
        return (lhs.id == rhs.id) && (lhs.name == rhs.name)
    }
    
    public let id = UUID()
    @Published var name: String 
    @Published var pages: [Page]
    
    @ObservedObject var library: Library
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
//        hasher.combine(pages)
    }

    
    init(withName name: String, pages: [Page]?, inLibrary: Library) {
        self.name = name
        if let p = pages {
            self.pages = p
        } else {
            self.pages = []
        }
        library = inLibrary
    }
    
    convenience init(inLibrary: Library, name: String, pages: [Page]?) {
        self.init(withName: name, pages: pages, inLibrary: inLibrary)
        
        
    }
    
    func addPage() {
        let toAppend = Page(number: "New Page", inAlbum: self)
        pages.append(toAppend)
    }
    
}


