import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:ota_update/ota_update.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String vInfo = '';
  String progress = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('版本升级'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
                color: Colors.black38,
                onPressed: _updateVersion,
                child: Text('版本升级')
            ),
            Container(
              child: Text('$vInfo'),
            ),
            Container(
              child: Text('$progress'),
            ),
          ],
        ),
      ),
    );
  }

  void _initData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    setState(() {
      vInfo = Platform.isIOS ? 'iOS_$version' : 'android_$version';
    });
  }

  void _updateVersion() async{
    if (Platform.isIOS){
      String url = 'itms-apps://itunes.apple.com/cn/app/id414478124?mt=8'; // 这是微信的地址，到时候换成自己的应用的地址
      if (await canLaunch(url)){
        await launch(url);
      }else {
        throw 'Could not launch $url';
      }
    }else if (Platform.isAndroid){
      String url = 'http://x2.c1578dn.cn/v13/hll/iReader.apk';
      try {
        OtaUpdate().execute(url).listen(
              (OtaEvent event) {
            print('status:${event.status},value:${event.value}');
            switch(event.status){
              case OtaStatus.DOWNLOADING: // 下载中
                setState(() {
                  progress = '下载进度:${event.value}%';
                });
                break;
              case OtaStatus.INSTALLING: //安装中
                break;
              case OtaStatus.PERMISSION_NOT_GRANTED_ERROR: // 权限错误
                print('更新失败，请稍后再试');
                break;
              default: // 其他问题
                break;
            }
          },
        );
      } catch (e) {
        print('更新失败，请稍后再试');
      }
    }
  }
}
