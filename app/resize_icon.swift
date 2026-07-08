import Cocoa
import CoreGraphics

func resizePNG(src: String, dst: String, size: Int) {
    guard let data     = try? Data(contentsOf: URL(fileURLWithPath: src)),
          let provider = CGDataProvider(data: data as CFData),
          let srcCG    = CGImage(pngDataProviderSource: provider, decode: nil,
                                 shouldInterpolate: true, intent: .defaultIntent)
    else { print("failed: \(src)"); return }

    let cs  = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(data: nil, width: size, height: size,
                              bitsPerComponent: 8, bytesPerRow: 0,
                              space: cs,
                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { print("ctx failed"); return }

    ctx.clear(CGRect(x: 0, y: 0, width: size, height: size))
    ctx.interpolationQuality = .high
    ctx.draw(srcCG, in: CGRect(x: 0, y: 0, width: size, height: size))

    guard let outCG  = ctx.makeImage(),
          let dest   = CGImageDestinationCreateWithURL(URL(fileURLWithPath: dst) as CFURL,
                                                       "public.png" as CFString, 1, nil)
    else { return }

    CGImageDestinationAddImage(dest, outCG, nil)
    CGImageDestinationFinalize(dest)
}

let src     = "../art/icon2.png"
let iconset = "FlashJam.iconset"
for s in [16, 32, 64, 128, 256, 512] {
    resizePNG(src: src, dst: "\(iconset)/icon_\(s)x\(s).png",    size: s)
    resizePNG(src: src, dst: "\(iconset)/icon_\(s)x\(s)@2x.png", size: s * 2)
}
resizePNG(src: src, dst: "\(iconset)/icon_512x512@2x.png", size: 1024)
print("done")
