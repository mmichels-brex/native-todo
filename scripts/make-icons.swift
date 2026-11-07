// Renders the two 1024x1024 app icons used to tell the builds apart:
//   assets/icon-rn.png                -> Expo/React Native host  (atom)
//   standalone/.../AppIcon.png        -> pure-native standalone  (Swift bird)
//
// Usage (from repo root):  swift scripts/make-icons.swift
//
// Note: the Swift bird is Apple's `swift` SF Symbol. SF Symbols' license does
// not permit use in app icons, so this is for internal experiments only.

import AppKit

let size = CGSize(width: 1024, height: 1024)

func render(to path: String, draw: (CGContext) -> Void) {
  let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Int(size.width), pixelsHigh: Int(size.height),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  draw(NSGraphicsContext.current!.cgContext)
  NSGraphicsContext.restoreGraphicsState()
  let url = URL(fileURLWithPath: path)
  try! FileManager.default.createDirectory(
    at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
  try! rep.representation(using: .png, properties: [:])!.write(to: url)
  print("wrote \(path)")
}

func fillGradient(_ ctx: CGContext, _ top: NSColor, _ bottom: NSColor) {
  let gradient = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [top.cgColor, bottom.cgColor] as CFArray, locations: [0, 1])!
  ctx.drawLinearGradient(
    gradient, start: CGPoint(x: 0, y: size.height), end: .zero, options: [])
}

// MARK: Native — Swift bird on a SwiftUI-style blue gradient

render(to: "standalone/TodoStandalone/Assets.xcassets/AppIcon.appiconset/AppIcon.png") { ctx in
  fillGradient(ctx,
               NSColor(srgbRed: 0.33, green: 0.62, blue: 1.00, alpha: 1),
               NSColor(srgbRed: 0.05, green: 0.25, blue: 0.85, alpha: 1))

  let config = NSImage.SymbolConfiguration(pointSize: 560, weight: .regular)
    .applying(.init(paletteColors: [.white]))
  let bird = NSImage(systemSymbolName: "swift", accessibilityDescription: nil)!
    .withSymbolConfiguration(config)!
  let rect = CGRect(
    x: (size.width - bird.size.width) / 2, y: (size.height - bird.size.height) / 2,
    width: bird.size.width, height: bird.size.height)
  bird.draw(in: rect)
}

// MARK: RN — atom on React's dark background

render(to: "assets/icon-rn.png") { ctx in
  NSColor(srgbRed: 0.125, green: 0.137, blue: 0.165, alpha: 1).setFill()  // #20232A
  ctx.fill(CGRect(origin: .zero, size: size))

  let cyan = NSColor(srgbRed: 0.38, green: 0.855, blue: 0.984, alpha: 1)  // #61DAFB
  let center = CGPoint(x: size.width / 2, y: size.height / 2)
  ctx.setStrokeColor(cyan.cgColor)
  ctx.setLineWidth(38)

  for angle in [0.0, 60.0, 120.0] {
    ctx.saveGState()
    ctx.translateBy(x: center.x, y: center.y)
    ctx.rotate(by: angle * .pi / 180)
    ctx.strokeEllipse(in: CGRect(x: -400, y: -155, width: 800, height: 310))
    ctx.restoreGState()
  }

  ctx.setFillColor(cyan.cgColor)
  ctx.fillEllipse(in: CGRect(x: center.x - 72, y: center.y - 72, width: 144, height: 144))
}
