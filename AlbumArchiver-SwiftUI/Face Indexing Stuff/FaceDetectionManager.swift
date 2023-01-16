//
//  FaceDetector.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 1/11/23.
//

import Foundation
import Vision
import CoreImage

struct FaceDetectionManager {
    
    enum DetectionMethod {
        case vision, coreImage
    }
    
    static func facesInItem(item: ArchivedItem, methodToUse: DetectionMethod = .vision) -> [FaceObservation]? {
        
        if let i = item.image {
            
            guard let imageToProcess = i.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                print("Couldn't convert image to CGImage")
                return []
            }
            
            
            switch methodToUse {
            case .coreImage:
                return detectUsingCoreImage(im: imageToProcess)
            case .vision:
                return detectUsingVision(im: imageToProcess)
            }
            
        } else {
            print("No image for item: \(item.name), returning")
            return []
        }
     
    }
    
    
    static func detectUsingCoreImage(im: CGImage) -> [FaceObservation] {
        // let's try CIDetector, too
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]

        let cifaceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)!

        let asCIImage = CIImage(cgImage: im)
        if let faces = cifaceDetector.features(in: asCIImage) as? [CIFaceFeature]
        {
//           print("faces from CIDetector: \(faces.count)")
            return faces.map { faceFeature in
                
                // CIFaceFeature's bounding box is in image coordinates, let's
                // turn those into normalized coordinates
                let projectedBox = VNNormalizedRectForImageRect(faceFeature.bounds, im.width, im.height)

                
                return FaceObservation(boundingBox: projectedBox, detectionType: .coreImage(obs: faceFeature))
            }
       } else {
            print("No faces found using CIDetector")
           return []
        }

    }
    
    static func detectUsingVision(im: CGImage) -> [FaceObservation] {
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: im,
                                                        orientation: .up,
                                                        options: [:])
        
        
        
        let faceRecognitionRequest = VNDetectFaceRectanglesRequest()
        
        
        do {
            try imageRequestHandler.perform([faceRecognitionRequest])
//                print("Faces from Vision: \(faceRecognitionRequest.results?.count)")
            if let r = faceRecognitionRequest.results {
                return r.map { obs in
                    FaceObservation(boundingBox: obs.boundingBox, detectionType: .vision(obs: obs))
                }
            } else {
                print("Got no results from faceRecognitionRequest")
                return []
            }
            
            
        } catch let e {
            print("Got vision error: \(e)")
            return []
        }
    }
    
}
