# NetShare
Data sharing in local network

<img width="772" alt="Screenshot 2023-01-11 at 21 39 25" src="https://user-images.githubusercontent.com/29337364/211834507-cd29722b-53ce-40f0-9ef5-350138406773.png">

[![Twitter URL](https://img.shields.io/twitter/url/https/twitter.com/blueaquilae.svg?style=social&label=Follow%20HuyNguyenTw)](https://twitter.com/HuyNguyenTw)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/I2I7LA2DY)

## Demo (Screenshots, Videos)

### Mobile

<img width="300" src="https://github.com/huynguyennovem/netshare/assets/29337364/55749d98-1d96-4c7f-a709-e33b96cb156a"> <img width="300" src="https://github.com/huynguyennovem/netshare/assets/29337364/f8e4ad71-ff86-4734-9709-90ddead3fd2c"> <img width="300" src="https://github.com/huynguyennovem/netshare/assets/29337364/2150f38b-3b91-405e-ba5f-5db8dba9904b">

### Desktop

<img width="600" src="https://github.com/huynguyennovem/netshare/assets/29337364/2ced719b-4516-451a-94e0-c9264d6b4e39"> <img width="600" src="https://github.com/huynguyennovem/netshare/assets/29337364/e90ae9d7-2475-489d-8845-8f3eb63bd1de"> <img width="600" src="https://github.com/huynguyennovem/netshare/assets/29337364/683c58ee-78b7-4c07-a371-da2eb1f276da">

### Video

https://github.com/huynguyennovem/netshare/assets/29337364/2e9caa89-d05a-48f5-ae79-6e69760962ad

## How to build the project
_Note: This project is mainly running on the latest Flutter beta channel_

1. Run Hive object generator (if needed)
The project's using (hive)[https://pub.dev/packages/hive] (NoSQL Database) to cache object data. Before running this, we should generate all entities adapters (being inside `.g.dart` files) to make sure all they are updated:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

2. Run the project as usual

```bash
flutter run
```

Normally, desktop app (macOS, Windows, Linux) will be server and mobile app (Android, iOS) will be client role. But roles can be reversed, let's try and enjoy :) 

**Note**
- Remember to connect both server and client app in the same network
- iOS:
To keep iOS app persisting on your device, recommend running it in release mode: `flutter run --release` (you can not reopen app if running it in debug mode)





