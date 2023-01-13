//
//  ArchivedItem.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 12/5/22.
//

import Foundation
import SwiftUI
import Cocoa

public class ArchivedItem : Identifiable, ObservableObject, Hashable {
    public static func == (lhs: ArchivedItem, rhs: ArchivedItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    @Published var name : String
    @Published var imageFileURL : URL?
    @Published var image : NSImage?
    @Published var notes : String
    
    public let id = UUID()
    
    init(withName: String, withImage: NSImage? = nil,atUrl: URL? = nil,  withNotes: String? = nil) {
        name = withName
        image = withImage
        imageFileURL = atUrl
        
        if let s = withNotes {
            notes = s
        } else {
            notes = ""
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public func attachItem(fromUrl: URL) {
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            // Try and make an image out of this URL; if it succeeds, we're good, otherwise
            // ignore it and move on
            let rawIm = NSImage(byReferencing: fromUrl)
            if rawIm.isValid {

                let fileName = fromUrl.lastPathComponent
                
                DispatchQueue.main.async {
                    // We need to do this on the main thread because these are @Published
                    self.imageFileURL = fromUrl
                    self.image = rawIm
                    self.name = fileName
                }
            }  else {
                    print("Could not load image from \(fromUrl)")
            }
                
            
            
        }
        
        

    }

    
}
