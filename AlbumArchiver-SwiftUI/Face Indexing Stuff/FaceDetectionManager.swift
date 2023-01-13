//
//  FaceDetector.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 1/11/23.
//

import Foundation
import Vision

struct FaceDetectionManager {
    
    static func facesInItem(item: ArchivedItem) -> [VNFaceObservation]? {
        
        if let i = item.image {
            
            guard let imageToProcess = i.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                print("Couldn't convert image to CGImage")
                return []
            }
            
            
            let imageRequestHandler = VNImageRequestHandler(cgImage: imageToProcess,
                                                            orientation: .up,
                                                            options: [:])
            
            let faceRecognitionRequest = VNDetectFaceRectanglesRequest()
            
            do {
                try imageRequestHandler.perform([faceRecognitionRequest])
                
                return faceRecognitionRequest.results
                
                
            } catch let e {
                print("Got vision error: \(e)")
                return []
            }
            
            
        } else {
            print("No image for item: \(item.name), returning")
            return []
        }
     
    }
    
    
}
