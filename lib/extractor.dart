library extractor;

import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class Extractor {
  ///Define timeout in second.
  ///
  ///[timeout], The more timeout you will give, more accurate results you will get.
  ///Many websites take more time to load, so direct url extraction will also take time.
  ///Minimum 6 seconds of timeout is recommended and default timeout is also set to 6 seconds
  ///
  Future<VideoData?> getDirectLink({String link = '', int timeout = 6}) async {
    VideoData? res;

    HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(utf8.decode(base64.decode('aHR0cHM6Ly9lbi5zYXZlZnJvbS5uZXQv')))),
      onLoadStop: (controller, url) async {
        await controller.evaluateJavascript(source: '''
document.querySelector('#sf_url').value = '$link'
document.querySelector('#sf_submit').click()
''');
        var data = await Future.delayed(const Duration(seconds: 3), () async {
          var htm = await controller.getHtml();
          var document = parse(htm);

          try {
            String? thumbnail = document.querySelector(".media-result .clip img")?.attributes['src'];

            var info = document.querySelector(".info-box");
            String? title = info?.querySelector(".title")?.text;
            String? duration = info?.querySelector(".duration")?.text;
            List<Element> linkGroup = [...info!.querySelectorAll(".link-group a")];

            List<Link> links = linkGroup.map((element) {
              String? videoFormat = element.attributes['title'];
              String? href = element.attributes['href'];
              String? text = element.text;
              return Link(videoFormat: videoFormat, href: href, text: text);
            }).toList();

            if (links.isEmpty) {
              Element? element = info.querySelector(".link-download");
              String? videoFormat = "";
              String? href = element?.attributes['href'];
              String? text = element?.text.replaceAll("Download", "").trim();
              links.add(Link(videoFormat: videoFormat, href: href, text: text));
            }

            VideoData vData = VideoData(
                status: true, message: 'Success', title: title, thumbnail: thumbnail, duration: duration, links: links);
            return vData;
          } catch (e) {
            return VideoData(status: false, message: 'Please try again');
          }
        });
        res = data;
      },
    )
      ..run()
      ..dispose();
    var result = Future.delayed(Duration(seconds: timeout), () {
      return res;
    });
    return result;
  }
}

class VideoData {
  VideoData({
    this.status,
    this.message,
    this.title,
    this.thumbnail,
    this.duration,
    this.links,
  });

  bool? status;
  String? message;
  String? title;
  String? thumbnail;
  String? duration;
  List<Link>? links;
}

class Link {
  Link({
    this.videoFormat,
    this.href,
    this.text,
  });

  String? videoFormat;
  String? href;
  String? text;
}
