//
//  ImageHelper.swift
//  PxChallenge
//
//  Created by Paul Floussov on 2017-04-18.
//  Copyright © 2017 Paul Floussov. All rights reserved.
//

import Foundation
import UIKit

public class ImageHelper {
    
    static func photoSizes(photos:[Photo], viewBounds: CGRect) -> [CGSize] {
        var output = [CGSize]()
        
        var index = 0
        var currentPhotos = [Photo]()
        while index < photos.count {
            currentPhotos.append(photos[index])
            let bestHeight = bestHightForPhotos(photos: currentPhotos, screenWidth: viewBounds.width)
            
            if (bestHeight <= Double(viewBounds.height / 4)) {
                for photo in currentPhotos {
                    output.append(CGSize(width:aspectRatio(photo: photo) * bestHeight ,height:bestHeight))
                }
                currentPhotos = [Photo]()
            }
            
            index += 1
        }
        
        for photo in currentPhotos {
            let generalHeight = Double(viewBounds.height / 5)
            
            output.append(CGSize(width:aspectRatio(photo: photo) * generalHeight, height:generalHeight))
        }
        
        return output
    }
    
    private static func aspectRatio(photo: Photo) -> Double {
        return Double(photo.width) / Double(photo.height)
    }
    
    private static func photoWidthAtHeight(photo: Photo, height:Int) -> Double {
        return aspectRatio(photo: photo) * Double(height)
    }
    
    private static func bestHightForPhotos(photos: [Photo], screenWidth: CGFloat) -> Double {
        let tempHeight = 500
        var totalWidth: Double = 0
        for photo in photos {
            totalWidth += photoWidthAtHeight(photo: photo, height: tempHeight)
        }
        
        let aspectRatio =  Double(tempHeight) / totalWidth
        
        return aspectRatio * Double(screenWidth - 0.1)
    }
}
