import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let sourceIconURL = root.appendingPathComponent("assets/generated/martillo.png")

struct IconTarget {
    let path: String
    let size: Int
}

let targets: [IconTarget] = [
    IconTarget(path: "assets/generated/app_icon_geological_hammer_1024.png", size: 1024),
    IconTarget(path: "android/app/src/main/res/mipmap-mdpi/ic_launcher.png", size: 48),
    IconTarget(path: "android/app/src/main/res/mipmap-hdpi/ic_launcher.png", size: 72),
    IconTarget(path: "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", size: 96),
    IconTarget(path: "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", size: 144),
    IconTarget(path: "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", size: 192),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png", size: 20),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png", size: 40),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png", size: 60),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png", size: 29),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png", size: 58),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png", size: 87),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png", size: 40),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png", size: 80),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png", size: 120),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png", size: 120),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png", size: 180),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png", size: 76),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png", size: 152),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png", size: 167),
    IconTarget(path: "ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png", size: 1024),
    IconTarget(path: "web/favicon.png", size: 32),
    IconTarget(path: "web/icons/Icon-192.png", size: 192),
    IconTarget(path: "web/icons/Icon-maskable-192.png", size: 192),
    IconTarget(path: "web/icons/Icon-512.png", size: 512),
    IconTarget(path: "web/icons/Icon-maskable-512.png", size: 512),
]

func color(_ hex: UInt32) -> NSColor {
    let r = CGFloat((hex >> 16) & 0xff) / 255.0
    let g = CGFloat((hex >> 8) & 0xff) / 255.0
    let b = CGFloat(hex & 0xff) / 255.0
    return NSColor(red: r, green: g, blue: b, alpha: 1)
}

func path(_ points: [CGPoint]) -> NSBezierPath {
    let p = NSBezierPath()
    guard let first = points.first else { return p }
    p.move(to: first)
    for point in points.dropFirst() {
        p.line(to: point)
    }
    p.close()
    return p
}

func drawIcon(size: Int) -> NSBitmapImageRep {
    let canvas = CGFloat(size)
    let scale = canvas / 1024.0
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphicsContext

    let ctx = graphicsContext.cgContext

    ctx.scaleBy(x: scale, y: scale)
    ctx.setShouldAntialias(true)
    ctx.setAllowsAntialiasing(true)

    let full = NSRect(x: 0, y: 0, width: 1024, height: 1024)
    color(0xffffff).setFill()
    NSBezierPath(rect: full).fill()

    guard let source = NSImage(contentsOf: sourceIconURL) else {
        fatalError("No se pudo cargar \(sourceIconURL.path)")
    }

    let maxSide: CGFloat = 870
    let imageSize = source.size
    let imageScale = min(maxSide / imageSize.width, maxSide / imageSize.height)
    let drawWidth = imageSize.width * imageScale
    let drawHeight = imageSize.height * imageScale
    let drawRect = NSRect(
        x: (1024 - drawWidth) / 2,
        y: (1024 - drawHeight) / 2,
        width: drawWidth,
        height: drawHeight
    )
    source.draw(in: drawRect, from: .zero, operation: .sourceOver, fraction: 1)

    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

func writePng(_ bitmap: NSBitmapImageRep, to url: URL) throws {
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconWriter", code: 1)
    }
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
}

for target in targets {
    let image = drawIcon(size: target.size)
    try writePng(image, to: root.appendingPathComponent(target.path))
    print("wrote \(target.path) \(target.size)x\(target.size)")
}
