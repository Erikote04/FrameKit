//
//  FrameGenerator.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import UIKit
import CoreGraphics

final class FrameGenerator {
    
    private let horizontalMargin: CGFloat = 60
    private let topMargin: CGFloat = 60
    private let bottomMargin: CGFloat = 180
    private let textBottomPadding: CGFloat = 40
    private let lineSpacing: CGFloat = 8
    
    func generateFramedImage(
        from originalImage: UIImage,
        metadata: PhotoMetadata
    ) -> UIImage? {
        let imageSize = originalImage.size
        let aspectRatio = imageSize.width / imageSize.height
        
        let frameWidth = imageSize.width + (horizontalMargin * 2)
        let frameHeight = imageSize.height + topMargin + bottomMargin
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = originalImage.scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: frameWidth, height: frameHeight),
            format: format
        )
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            UIColor.white.setFill()
            cgContext.fill(CGRect(x: 0, y: 0, width: frameWidth, height: frameHeight))
            
            let imageRect = CGRect(
                x: horizontalMargin,
                y: topMargin,
                width: imageSize.width,
                height: imageSize.height
            )
            originalImage.draw(in: imageRect)
            
            drawMetadataText(
                in: cgContext,
                metadata: metadata,
                frameWidth: frameWidth,
                imageBottom: topMargin + imageSize.height
            )
        }
    }
    
    private func drawMetadataText(
        in context: CGContext,
        metadata: PhotoMetadata,
        frameWidth: CGFloat,
        imageBottom: CGFloat
    ) {
        let textY = imageBottom + textBottomPadding
        
        drawDeviceLine(
            in: context,
            text: metadata.formattedDevice,
            deviceModel: metadata.deviceModel,
            centerX: frameWidth / 2,
            y: textY
        )
        
        drawSpecsLine(
            in: context,
            text: metadata.formattedSpecs,
            centerX: frameWidth / 2,
            y: textY + 40 + lineSpacing
        )
    }
    
    private func drawDeviceLine(
        in context: CGContext,
        text: String,
        deviceModel: String,
        centerX: CGFloat,
        y: CGFloat
    ) {
        let normalFont = UIFont.systemFont(ofSize: 32, weight: .regular)
        let boldFont = UIFont.systemFont(ofSize: 32, weight: .bold)
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.black
        ]
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont,
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "Shot on ", attributes: normalAttributes))
        attributedString.append(NSAttributedString(string: deviceModel, attributes: boldAttributes))
        
        let textSize = attributedString.size()
        let textX = centerX - (textSize.width / 2)
        
        attributedString.draw(at: CGPoint(x: textX, y: y))
    }
    
    private func drawSpecsLine(
        in context: CGContext,
        text: String,
        centerX: CGFloat,
        y: CGFloat
    ) {
        let font = UIFont.systemFont(ofSize: 24, weight: .regular)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textX = centerX - (textSize.width / 2)
        
        attributedString.draw(at: CGPoint(x: textX, y: y))
    }
}
