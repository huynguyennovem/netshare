# NetShare
Data sharing in local network

<img width="772" alt="Screenshot 2023-01-11 at 21 39 25" src="https://user-images.githubusercontent.com/29337364/211834507-cd29722b-53ce-40f0-9ef5-350138406773.png">


## Demo (Screenshots, Video)

### Mobile

<img width="300" src="https://user-images.githubusercontent.com/29337364/211847045-dcf96b7d-22e8-45e2-8edb-eb5115c22f46.png"> <img width="300" src="https://user-images.githubusercontent.com/29337364/211847070-06ba416d-f502-44b2-a541-ed51a02083b6.png">

### Desktop

Server | Client
-------- | ----------
<img width="600" src="https://user-images.githubusercontent.com/29337364/211842356-37c40e4a-7647-4754-84f4-738dfab818c8.png"> | <img width="600" src="https://user-images.githubusercontent.com/29337364/211847463-3fbf8bd8-39cf-4af9-81e2-68b644d78910.png">

### Video

https://user-images.githubusercontent.com/29337364/211870449-dd80c199-e64a-4c21-af46-a1aceea9b61c.mp4

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





