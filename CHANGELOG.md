## 1.0.0

* The first MVP version

## 2.0.0

🎊 New features
- Release Windows and Linux
- Switching between Client and Server modes
- File mime type icon
- Download/Open file and file state
- Open sharing native directory
- Display server uptime
- QR Connect method
- Drag-drop and remove files on the uploading screen
- Limit window size on desktop
- Friendly desktop UI/UX

🐞 Bug fixes
- https://github.com/huynguyennovem/netshare/issues/47: The old file URL is wrong
- https://github.com/huynguyennovem/netshare/issues/35: Bad state when switching to Client mode
- https://github.com/huynguyennovem/netshare/issues/33: RangeError when picking a file without extension
- https://github.com/huynguyennovem/netshare/issues/24: Desktop app does not have minimum size that causes overflowed when resizing
- https://github.com/huynguyennovem/netshare/issues/56: Android terminal can not host non-media files on Android 11 and above

## 2.1.0
🎊 New features
- Flutter 3.10 new feature (BottomSheet showDragHandle on list files, add SearchAnchor)

🐞 Bug fixes
- https://github.com/huynguyennovem/netshare/issues/61: List files item hover color is overflowing to outside
- https://github.com/huynguyennovem/netshare/issues/67: Can not download file having empty character in name on iOS
- https://github.com/huynguyennovem/netshare/issues/66: File is downloaded but the state is not updated properly on iOS
- https://github.com/huynguyennovem/netshare/issues/69: Comma key is displayed instead of dot key on iOS
- https://github.com/huynguyennovem/netshare/issues/72: Can not pick media files (image, video) in client mode on iOS
- https://github.com/huynguyennovem/netshare/issues/76: Crashing when hosting file on iOS

## 2.2.0
🎊 New features
- Compatible with Flutter 3.38
- Migrate Android Gradle to Kotlin DSL
- Send text feature
