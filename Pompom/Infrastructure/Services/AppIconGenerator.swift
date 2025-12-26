import AppKit
import SwiftUI

final class AppIconGenerator {
    
    static func generateAppIcon(size: CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        
        image.lockFocus()
        
        let rect = NSRect(x: 0, y: 0, width: size, height: size)
        let cornerRadius = size * 0.22
        
        let gradient = NSGradient(colors: [
            NSColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0),
            NSColor(red: 1.0, green: 0.45, blue: 0.0, alpha: 1.0)
        ])
        
        let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
        gradient?.draw(in: path, angle: -45)
        
        let timerConfig = NSImage.SymbolConfiguration(pointSize: size * 0.5, weight: .medium)
        if let timerSymbol = NSImage(systemSymbolName: "timer", accessibilityDescription: nil)?
            .withSymbolConfiguration(timerConfig) {
            
            let symbolSize = timerSymbol.size
            let symbolRect = NSRect(
                x: (size - symbolSize.width) / 2,
                y: (size - symbolSize.height) / 2,
                width: symbolSize.width,
                height: symbolSize.height
            )
            
            NSColor.white.setFill()
            timerSymbol.draw(in: symbolRect, from: .zero, operation: .sourceOver, fraction: 1.0)
        }
        
        image.unlockFocus()
        
        return image
    }
    
    static func exportIcons(to directory: URL) throws {
        let sizes: [(size: Int, scale: Int, name: String)] = [
            (16, 1, "icon_16x16"),
            (16, 2, "icon_16x16@2x"),
            (32, 1, "icon_32x32"),
            (32, 2, "icon_32x32@2x"),
            (128, 1, "icon_128x128"),
            (128, 2, "icon_128x128@2x"),
            (256, 1, "icon_256x256"),
            (256, 2, "icon_256x256@2x"),
            (512, 1, "icon_512x512"),
            (512, 2, "icon_512x512@2x")
        ]
        
        for spec in sizes {
            let pixelSize = CGFloat(spec.size * spec.scale)
            let icon = generateAppIcon(size: pixelSize)
            
            guard let tiffData = icon.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let pngData = bitmap.representation(using: .png, properties: [:]) else {
                continue
            }
            
            let fileURL = directory.appendingPathComponent("\(spec.name).png")
            try pngData.write(to: fileURL)
        }
    }
}

struct AppIconView: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.96, green: 0.26, blue: 0.21),
                            Color(red: 1.0, green: 0.45, blue: 0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .red.opacity(0.3), radius: size * 0.05, y: size * 0.02)
            
            Image(systemName: "timer")
                .font(.system(size: size * 0.45, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
    }
}

struct MenuBarIconView: View {
    let isRunning: Bool
    let sessionType: SessionType
    
    var iconColor: Color {
        if !isRunning {
            return .primary
        }
        switch sessionType {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
    
    var body: some View {
        Image(systemName: sessionType.icon)
            .symbolRenderingMode(.hierarchical)
            .foregroundColor(iconColor)
    }
}

#Preview("App Icon") {
    HStack(spacing: 20) {
        AppIconView(size: 32)
        AppIconView(size: 64)
        AppIconView(size: 128)
        AppIconView(size: 256)
    }
    .padding()
}
