import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:r34_browser/detail_page.dart';
import 'package:r34_browser/themes.dart';
import 'package:xml/xml.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'r34 Browser',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<R34Image> _images = List();

  @override
  void initState() {
    super.initState();
    request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text('r34 Browser', style: TextStyle(color: textColor),),
        ),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(8),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: _images.map(_buildImage).toList(),
        ));
  }

  Widget _buildImage(R34Image image) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return DetailPage(image.fileUrl);
        }));
      },
      child: ExtendedImage.network(
        image.thumbnailUrl,
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.width / 2,
        fit: BoxFit.cover,
      ),
    );
  }

  void request() async {
    // Dio dio = Dio();
    // Response<String> response = await dio.request(
    //     'https://rule34.xxx/index.php?page=dapi&tags=fireboxstudio&s=post&limit=10&q=index');
    // print(response);

    String xml = '<?xml version="1.0" encoding="UTF-8"?><posts count="563" offset="0"><post height="729" score="36" file_url="https://himg.rule34.xxx/images/3750/7e9ff8a63fe2079f47ff48a5c309c3ed.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3750/sample_7e9ff8a63fe2079f47ff48a5c309c3ed.jpg"  sample_width="850" sample_height="478" preview_url="https://rule34.xxx/thumbnails/3750/thumbnail_7e9ff8a63fe2079f47ff48a5c309c3ed.jpg" rating="e" tags=" 3girls aerith_gainsborough blonde_hair brown_hair cunnilingus facesitting fff_threesome final_fantasy final_fantasy_vii final_fantasy_vii_remake final_fantasy_xv fireboxstudio flowers lesbian long_hair lunafreya_nox_fleuret naked nude nude_female square_enix strap-on tagme threesome tifa_lockhart uncensored yuri " id="4243492" width="1296"  change="1606202443" md5="7e9ff8a63fe2079f47ff48a5c309c3ed" creator_id="655834" has_children="false" created_at="Thu Nov 19 00:57:46 +0000 2020" status="active" source="" has_notes="false" has_comments="true" preview_width="150" preview_height="84"/><post height="729" score="50" file_url="https://himg.rule34.xxx/images/3750/3bca8ad395d11ca8f58a8e109ac74efa.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3750/sample_3bca8ad395d11ca8f58a8e109ac74efa.jpg"  sample_width="850" sample_height="478" preview_url="https://rule34.xxx/thumbnails/3750/thumbnail_3bca8ad395d11ca8f58a8e109ac74efa.jpg" rating="e" tags=" 3girls aerith_gainsborough blonde_hair brown_hair cunnilingus dildo facesitting fff_threesome final_fantasy final_fantasy_vii final_fantasy_vii_remake final_fantasy_xv fireboxstudio lesbian long_hair lunafreya_nox_fleuret naked nude nude_female square_enix strap-on tagme threesome tifa_lockhart uncensored yuri " id="4243491" width="1296"  change="1606202490" md5="3bca8ad395d11ca8f58a8e109ac74efa" creator_id="655834" has_children="false" created_at="Thu Nov 19 00:57:14 +0000 2020" status="active" source="" has_notes="false" has_comments="false" preview_width="150" preview_height="84"/><post height="1080" score="79" file_url="https://himg.rule34.xxx/images/3741/7a5c215f7d45768de952d4ae10cc3a8a.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3741/sample_7a5c215f7d45768de952d4ae10cc3a8a.jpg"  sample_width="850" sample_height="478" preview_url="https://rule34.xxx/thumbnails/3741/thumbnail_7a5c215f7d45768de952d4ae10cc3a8a.jpg" rating="e" tags=" 2girls 3d areolae arms_behind_back ass back_view ball_gag boots d.va elbow_gloves eyeshadow female female_only femdom femsub fingering fireboxstudio gag hands_behind_back harness high_heels latex latex_gloves latex_stockings latex_suit latex_thighhighs leg_up mercy nipples overwatch pussy_juice smile stockings thighhighs wet_pussy yuri " id="4232870" width="1920"  change="1605867501" md5="7a5c215f7d45768de952d4ae10cc3a8a" creator_id="123168" has_children="false" created_at="Sat Nov 14 19:12:10 +0000 2020" status="active" source="https://twitter.com/FireboxStudio/status/1327687931360923648" has_notes="false" has_comments="true" preview_width="150" preview_height="84"/><post height="900" score="137" file_url="https://himg.rule34.xxx/images/3741/950799241f940021e81927a495e2035f.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3741/sample_950799241f940021e81927a495e2035f.jpg"  sample_width="850" sample_height="398" preview_url="https://rule34.xxx/thumbnails/3741/thumbnail_950799241f940021e81927a495e2035f.jpg" rating="e" tags=" 2girls 3d areolae arms_behind_back ball_gag boots breasts breasts_out breasts_outside d.va elbow_gloves eyeshadow female female_only femdom femsub fingering fireboxstudio gag hands_behind_back harness high_heels hourglass_figure large_breasts latex latex_gloves latex_stockings latex_suit latex_thighhighs leg_up lesbian mercy nipples overwatch pleasure_face red_ball_gag smile spread_legs stockings thighhighs wet_pussy yuri " id="4232869" width="1920"  change="1605938856" md5="950799241f940021e81927a495e2035f" creator_id="123168" has_children="false" created_at="Sat Nov 14 19:12:05 +0000 2020" status="active" source="https://twitter.com/FireboxStudio/status/1327687931360923648" has_notes="false" has_comments="true" preview_width="150" preview_height="70"/><post height="720" score="23" file_url="https://himg.rule34.xxx/images/3727/116c1d84917aea1212cb21ed8594e038.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3727/sample_116c1d84917aea1212cb21ed8594e038.jpg"  sample_width="850" sample_height="478" preview_url="https://rule34.xxx/thumbnails/3727/thumbnail_116c1d84917aea1212cb21ed8594e038.jpg" rating="e" tags=" breasts exposed_breasts exposed_nipples exposed_pussy fireboxstudio gets mercy nipples overwatch thighhighs " id="4216792" width="1280"  change="1604821930" md5="116c1d84917aea1212cb21ed8594e038" creator_id="361115" has_children="false" created_at="Sun Nov 08 07:52:10 +0000 2020" status="active" source="" has_notes="false" has_comments="false" preview_width="150" preview_height="84"/><post height="1260" score="92" file_url="https://himg.rule34.xxx/images/3725/a3de796422c8ebcca45afb1e3edfd170.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3725/sample_a3de796422c8ebcca45afb1e3edfd170.jpg"  sample_width="850" sample_height="558" preview_url="https://rule34.xxx/thumbnails/3725/thumbnail_a3de796422c8ebcca45afb1e3edfd170.jpg" rating="e" tags=" 3d 4girls areolae ashe_(overwatch) ball_gag blender breasts d.va female female_only fireboxstudio mercy nipples overwatch red_ball_gag sombra strap-on yuri " id="4215250" width="1920"  change="1605867673" md5="a3de796422c8ebcca45afb1e3edfd170" creator_id="123168" has_children="false" created_at="Sat Nov 07 20:31:22 +0000 2020" status="active" source="https://twitter.com/FireboxStudio/status/1325173853908324352" has_notes="false" has_comments="true" preview_width="150" preview_height="98"/><post height="1075" score="87" file_url="https://himg.rule34.xxx/images/3709/466bec1f2d17733edd3d3fc258a51e6a.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3709/sample_466bec1f2d17733edd3d3fc258a51e6a.jpg"  sample_width="850" sample_height="595" preview_url="https://rule34.xxx/thumbnails/3709/thumbnail_466bec1f2d17733edd3d3fc258a51e6a.jpg" rating="e" tags=" 3d 3girls areolae blender breasts disney elsa_(frozen) female female_only fireboxstudio frozen_(movie) mei_(overwatch) mercy nipples overwatch pussy sex spread_legs straight " id="4197370" width="1536"  change="1604169250" md5="466bec1f2d17733edd3d3fc258a51e6a" creator_id="123168" has_children="false" created_at="Sat Oct 31 18:34:09 +0000 2020" status="active" source="https://twitter.com/FireboxStudio/status/1322607033439367168" has_notes="false" has_comments="true" preview_width="150" preview_height="104"/><post height="756" score="104" file_url="https://himg.rule34.xxx/images/3694/3b88fbd3a1995a97fbccc837ae2fb2e1.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3694/sample_3b88fbd3a1995a97fbccc837ae2fb2e1.jpg"  sample_width="850" sample_height="478" preview_url="https://rule34.xxx/thumbnails/3694/thumbnail_3b88fbd3a1995a97fbccc837ae2fb2e1.jpg" rating="e" tags=" 2boys 2girls 3d alternate_costume anal anal_sex anus areolae balls breasts d.va erection female fireboxstudio male nipples overwatch penetration penis pussy sex shin-ryeong_d.va spread_legs straight testicles witch_mercy " id="4179664" width="1344"  change="1603570934" md5="3b88fbd3a1995a97fbccc837ae2fb2e1" creator_id="123168" has_children="false" created_at="Sat Oct 24 20:22:13 +0000 2020" status="active" source="https://twitter.com/FireboxStudio/status/1320084418485243904" has_notes="false" has_comments="true" preview_width="150" preview_height="84"/><post height="1296" score="95" file_url="https://himg.rule34.xxx/images/3674/8311f4ad7f7bd2103fd7dcb9bf87bfba.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3674/sample_8311f4ad7f7bd2103fd7dcb9bf87bfba.jpg"  sample_width="850" sample_height="478" preview_url="https://rule34.xxx/thumbnails/3674/thumbnail_8311f4ad7f7bd2103fd7dcb9bf87bfba.jpg" rating="e" tags=" 2girls 3d after_sex anus areolae breasts brigitte creampie cum cum_in_pussy cum_inside female female_only fireboxstudio looking_at_viewer mercy nipples nude overwatch pussy spread_legs spread_pussy yuri " id="4157291" width="2304"  change="1605867760" md5="8311f4ad7f7bd2103fd7dcb9bf87bfba" creator_id="123168" has_children="false" created_at="Fri Oct 16 21:45:29 +0000 2020" status="active" source="https://twitter.com/FireboxStudio/status/1317211979858235395" has_notes="false" has_comments="true" preview_width="150" preview_height="84"/><post height="796" score="82" file_url="https://himg.rule34.xxx/images/3654/556f17907c401e2bd1cc9280ecf3c5fb.jpeg" parent_id="" sample_url="https://rule34.xxx/samples/3654/sample_556f17907c401e2bd1cc9280ecf3c5fb.jpg"  sample_width="850" sample_height="529" preview_url="https://rule34.xxx/thumbnails/3654/thumbnail_556f17907c401e2bd1cc9280ecf3c5fb.jpg" rating="e" tags=" 2girls 3d ada_wong all_fours anal anal_penetration asian_female breasts breasts_out breasts_outside brown-tinted_eyewear choker claire_redfield cum cum_in_ass cum_in_mouth cum_in_pussy cum_inside fireboxstudio garter_straps high_heels interspecies leg_grab looking_over_eyewear looking_over_glasses no_bra no_panties no_pants open_mouth oral resident_evil resident_evil_2 resident_evil_2_remake stockings sunglasses tentacle tentacle_monster tentacle_sex thighhighs tinted_eyewear tongue tongue_out " id="4131816" width="1280"  change="1604174472" md5="556f17907c401e2bd1cc9280ecf3c5fb" creator_id="627133" has_children="false" created_at="Mon Oct 05 11:00:20 +0000 2020" status="active" source="" has_notes="false" has_comments="true" preview_width="150" preview_height="93"/></posts>';

    final document = XmlDocument.parse(xml);

    final posts = document.findAllElements('post');
    
    setState(() {
      for (var post in posts) {
        final fileUrl = post.getAttribute('file_url');
        final thumbnailUrl = post.getAttribute('preview_url');
        _images.add(R34Image(fileUrl, thumbnailUrl));
      } 
    });
  }
}

class R34Image {
  final String fileUrl;
  final String thumbnailUrl;

  R34Image(this.fileUrl, this.thumbnailUrl);
}
