import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {

        let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
        let openSharingChannel = FlutterMethodChannel(name: "com.app.netshare/open-sharing-dir",
                                                      binaryMessenger: controller.engine.binaryMessenger)
        openSharingChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

            guard let path = (call.arguments as? NSDictionary)?["path"] as? String else {
                result(FlutterMethodNotImplemented)
                return
            }
            switch call.method {
                case "openSharingDir":
                    let rs = self.openSharingDir(path: path, result: result);
                    result(rs)
                default:
                    result(FlutterMethodNotImplemented)
            }
        })
    }

    func openSharingDir(path: String, result: FlutterResult) -> Bool {
        if(!isPathExist(path: path)) {
            return false
        }
        let url = URL(fileURLWithPath: path, isDirectory: true)
        NSWorkspace.shared.activateFileViewerSelecting([url])
        return true
    }

    func isPathExist(path: String) -> Bool {
        var isDir : ObjCBool = true
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }
}
