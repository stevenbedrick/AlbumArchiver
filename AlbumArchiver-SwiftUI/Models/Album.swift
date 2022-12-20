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
    
    var memberOf: Library
    
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
//        hasher.combine(pages)
    }

    
    init(inLibrary: Library, name: String, pages: [Page]?) {
        self.name = name
        if let p = pages {
            self.pages = p
        } else {
            self.pages = []
        }
        memberOf = inLibrary
        
    }
    
    func addPage() {
        pages.append(Page(number: "New Page"))
    }
    
}


