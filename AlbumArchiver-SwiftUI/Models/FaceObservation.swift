//
//  FaceObservation.swift
//  AlbumArchiver-SwiftUI
//
//  Created by Steven Bedrick on 1/15/23.
//

import Foundation
import Vision
import CoreImage



struct FaceObservation : Identifiable, Hashable {

    
    
    enum FaceObservationType {
        case manuallyDrawn
        case vision(obs: VNFaceObservation?)
        case coreImage(obs: CIFaceFeature?)
    }
    
    
    let id = UUID()

    // Note: coordintes for bounding box might vary in their
    // interpretation according to the underlying type...
    let boundingBox : CGRect
    let type : FaceObservationType
    
    init(boundingBox: CGRect, detectionType: FaceObservationType) {
        self.boundingBox = boundingBox
        self.type = detectionType
    }
    
    static func == (lhs: FaceObservation, rhs: FaceObservation) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
}
