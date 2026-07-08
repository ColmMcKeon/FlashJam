import Cocoa

let size = CGFloat(1024)
let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

let ctx = NSGraphicsContext.current!.cgContext

// Purple rounded rect bg
let bg = CGColor(red: 0.545, green: 0.486, blue: 0.976, alpha: 1)
ctx.setFillColor(bg)
let path = CGPath(roundedRect: CGRect(x:0,y:0,width:size,height:size), cornerWidth: 200, cornerHeight: 200, transform: nil)
ctx.addPath(path); ctx.fillPath()

// White waveform bars centred
let white = CGColor(red:1,green:1,blue:1,alpha:0.92)
ctx.setFillColor(white)
let heights: [CGFloat] = [120,180,280,360,440,400,480,400,440,360,280,180,120]
let n = CGFloat(heights.count)
let bw: CGFloat = 36
let gap: CGFloat = 20
let total = n*bw + (n-1)*gap
var x = (size - total) / 2
let cy = size / 2
for h in heights {
    let r = CGRect(x: x, y: cy - h/2, width: bw, height: h)
    let bp = CGPath(roundedRect: r, cornerWidth: bw/2, cornerHeight: bw/2, transform: nil)
    ctx.addPath(bp); ctx.fillPath()
    x += bw + gap
}

img.unlockFocus()
let tiff = img.tiffRepresentation!
let rep = NSBitmapImageRep(data: tiff)!
let png = rep.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: "icon_1024.png"))
print("done")
