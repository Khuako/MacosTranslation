import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame

    self.isOpaque = false
    self.backgroundColor = NSColor.clear
    self.hasShadow = false
    flutterViewController.backgroundColor = NSColor.clear

    self.contentViewController = flutterViewController
    self.contentView?.wantsLayer = true
    self.contentView?.layer?.isOpaque = false
    self.contentView?.layer?.backgroundColor = NSColor.clear.cgColor
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.isOpaque = false
    flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor

    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
