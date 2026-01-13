//
//  FrameGenerator.swift
//  FrameKit
//
//  Created by Erik Sebastian de Erice Jerez on 13/1/26.
//

import UIKit
import CoreGraphics

final class FrameGenerator {
    
    private let horizontalMargin: CGFloat = 80
    private let topMargin: CGFloat = 80
    private let bottomMargin: CGFloat = 320
    private let textBottomPadding: CGFloat = 60
    private let lineSpacing: CGFloat = 20
    
    func generateFramedImage(
        from originalImage: UIImage,
        metadata: PhotoMetadata
    ) -> UIImage? {
        let imageSize = originalImage.size
        
        let scaleFactor: CGFloat = 0.85
        let scaledImageWidth = imageSize.width * scaleFactor
        let scaledImageHeight = imageSize.height * scaleFactor
        
        let frameWidth = scaledImageWidth + (horizontalMargin * 2)
        let frameHeight = scaledImageHeight + topMargin + bottomMargin
        
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
                width: scaledImageWidth,
                height: scaledImageHeight
            )
            originalImage.draw(in: imageRect)
            
            drawMetadataText(
                in: cgContext,
                metadata: metadata,
                frameWidth: frameWidth,
                imageBottom: topMargin + scaledImageHeight
            )
        }
    }
    
    private func drawMetadataText(
        in context: CGContext,
        metadata: PhotoMetadata,
        frameWidth: CGFloat,
        imageBottom: CGFloat
    ) {
        let bottomAreaHeight = bottomMargin
        let bottomAreaTop = imageBottom
        _ = imageBottom + bottomAreaHeight

        let titleFontSize = frameWidth * 0.024
        let specsFontSize = frameWidth * 0.018

        let titleFont = UIFont.systemFont(ofSize: titleFontSize, weight: .regular)
        let titleBoldFont = UIFont.systemFont(ofSize: titleFontSize, weight: .bold)
        let specsFont = UIFont.systemFont(ofSize: specsFontSize, weight: .regular)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let title = NSMutableAttributedString(
            string: "Shot on ",
            attributes: [
                .font: titleFont,
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
        )

        title.append(NSAttributedString(
            string: metadata.deviceModel,
            attributes: [
                .font: titleBoldFont,
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
        ))

        let specs = NSAttributedString(
            string: metadata.formattedSpecs,
            attributes: [
                .font: specsFont,
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
        )

        let titleSize = title.size()
        let specsSize = specs.size()
        let lineSpacing: CGFloat = 8

        let totalTextHeight = titleSize.height + lineSpacing + specsSize.height

        let startY = bottomAreaTop + (bottomAreaHeight - totalTextHeight) / 2

        let titleRect = CGRect(
            x: (frameWidth - titleSize.width) / 2,
            y: startY,
            width: titleSize.width,
            height: titleSize.height
        )

        let specsRect = CGRect(
            x: (frameWidth - specsSize.width) / 2,
            y: titleRect.maxY + lineSpacing,
            width: specsSize.width,
            height: specsSize.height
        )

        title.draw(in: titleRect)
        specs.draw(in: specsRect)
    }


    private func drawDeviceLine(
        in context: CGContext,
        text: String,
        deviceModel: String,
        centerX: CGFloat,
        y: CGFloat,
        fontSize: CGFloat
    ) {
        let normalFont = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        let boldFont = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        
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
        y: CGFloat,
        fontSize: CGFloat
    ) {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textX = centerX - (textSize.width / 2)
        
        attributedString.draw(at: CGPoint(x: textX, y: y))
    }
    
    private func perceptualFontSize(
        canvasWidth: CGFloat,
        baseWidth: CGFloat = 4000,
        baseFontSize: CGFloat,
        min minSize: CGFloat,
        max maxSize: CGFloat
    ) -> CGFloat {
        let scale = sqrt(canvasWidth / baseWidth)
        let size = baseFontSize * scale
        return Swift.min(Swift.max(size, minSize), maxSize)
    }
}
