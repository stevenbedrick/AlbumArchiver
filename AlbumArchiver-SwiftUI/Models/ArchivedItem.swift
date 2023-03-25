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
    @Published var image : NSImage? { didSet {
        self.detectFaces()
    }}
    
    @Published var notes : String
    
    @Published var faces : [FaceObservation] = []
    
    @Published var people : [Person] = []
    
    @ObservedObject var page : Page // the page this is on
    
    public let id = UUID()
    
    init(withName: String, onPage: Page, withImage: NSImage? = nil, atUrl: URL? = nil,  withNotes: String? = nil) {
        name = withName
        image = withImage
        imageFileURL = atUrl
        page = onPage
        
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
            let rawIm = NSImage(contentsOf: fromUrl)
            
            if rawIm != nil && rawIm!.isValid {

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
    
    func detectFaces() {
        DispatchQueue.global(qos: .background   ).async {
            if let f = FaceDetectionManager.facesInItem(item: self, methodToUse: .vision) {
                DispatchQueue.main.async {
                    self.faces = f
                }
            }
        }
    }
    
    func removeDetectedFace(faceToRemove: FaceObservation, withUndoManager undoManager: UndoManager? = nil) {
        DispatchQueue.main.async {
            self.faces.removeAll { someFaceObs in
                someFaceObs == faceToRemove
            }
            
            undoManager?.registerUndo(withTarget: self) { anArchivedItem in
                anArchivedItem.addDetectedFace(faceToAdd: faceToRemove, withUndoManager: undoManager)
            }
            undoManager?.setActionName("Remove Face")
        }
    }
    
    func addDetectedFace(faceToAdd: FaceObservation, withUndoManager undoManager: UndoManager? = nil) {
        // TODO: maybe check to make sure that we don't already have this same FaceObservation?
        DispatchQueue.main.async {
            self.faces.append(faceToAdd)
        }
    }

    
}
