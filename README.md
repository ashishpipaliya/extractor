<div align="center">
<img src="https://user-images.githubusercontent.com/32923529/167305467-81be9698-8101-4d23-a79e-d95d67b08aed.png" width="120"/>
<br>
<br>
<h2>extractor
</h2>
<p>Extract direct video links from video websites like youtube, vimeo and many more.</p>

![GitHub repo size](https://img.shields.io/github/repo-size/ashishpipaliya/extractor?style=for-the-badge)
![GitHub](https://img.shields.io/github/license/ashishpipaliya/extractor?style=for-the-badge)

<br/>
<img src="https://user-images.githubusercontent.com/32923529/167307269-187aaa44-0627-4370-8aff-fbc70cbe3204.gif" width="250"/>
<br/>
</div>

## 🌈 Supported Websites

- youtube.com
- dailymotion.com
- vimeo.com
- yandex.video
- facebook.com
- instagram.com
- soundcloud.com
- twitter.com
- tiktok.com
- vk.com
- odnoklassniki.ru
- bilibili.com
- hotstar.com
- openloadmovies.net
- streamago.com
- tune.pk
- viu.com


## 🔥 Usage

Add the dependency in `pubspec.yaml`:

```yaml
dependencies:
  ...
  extractor: ^0.0.1
```


```dart
void getData()async{
  List<VideoData> results = Extractor().getDirectLink(link: 'https://www.youtube.com/watch?v=Ne7y9_AbBsY');
}
```

`VideoData` class consists of following,

```dart
bool? status;
String? message;
String? title;
String? thumbnail;
String? duration;
List<Link>? links;
```

## ✍️ Authors

- [**Ashish Pipaliya**](https://github.com/ashishpipaliya) - _Author_

## 📜 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT) - see the [LICENSE](LICENSE) file for details.