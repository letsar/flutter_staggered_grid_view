

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

CacheManager cacheManager = CacheManager(Config('sliver_staggered',maxNrOfCacheObjects: 30));

class SliverStaggeredImagePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return SliverStaggeredImagePageState();
  }

}

class SliverStaggeredImagePageState extends State<SliverStaggeredImagePage> {

  late RefreshController _refreshController;
  late Size _screenSize;

  final List<String> _imgList = [];

  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imgList.addAll(rawData.sublist(0,10));
    _refreshController = RefreshController();
  }

  Future _loadMore() {
    final Completer<void> c = Completer();
    Future.delayed(const Duration(seconds: 1), () {
      if(_pageIndex * 10 < rawData.length) {
        _pageIndex++;

        final start = _pageIndex * 10;
        final end = _pageIndex * 10 + 10;

        setState(() {
          _imgList.addAll(rawData.sublist(start, end > rawData.length ? rawData.length : end));
        });
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }

      c.complete();
    });
    return c.future;
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Material(
      color: Colors.white,
      child: Scaffold(
        body: _buildPageBody(),
      ),
    );
  }

  Widget _buildPageBody() {
    return SmartRefresher(
        controller: _refreshController,
        header: const WaterDropHeader(),
        footer: const ClassicFooter(),
        enablePullUp: true,
        onLoading: _loadMore,
        child: CustomScrollView(
          slivers: [
            _emptyBoxWithColor(width: _screenSize.width,height: 100,color: Colors.blue),
            _emptyBoxWithColor(height: 10,),
            _emptyBoxWithColor(width: _screenSize.width,height: 200,color: Colors.lightGreen),
            _emptyBoxWithColor(height: 10,),
            _buildSliverStaggered(),
          ],
        ),);

  }

  Widget _buildSliverStaggered() {
    return SliverStaggeredGrid.countBuilder(
        mainAxisSpacing: 10,crossAxisSpacing: 10,
        crossAxisCount: 4,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
        itemBuilder: (ctx, index) {
          return _buildImgItem(index);
        },
        itemCount: _imgList.length);
  }

  Widget _buildImgItem(int index) {
    return CachedNetworkImage(imageUrl: _imgList[index],cacheManager: cacheManager,);
  }

  Widget _emptyBoxWithColor({double width = 1, double height = 1, Color color = Colors.white}) {
    return _wrapWidget(Container(
      width: width, height: height,
      color: color,));
  }

  SliverToBoxAdapter _wrapWidget(Widget child) {
    return SliverToBoxAdapter(child: child,);
  }

}

const List<String> rawData = [
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201804%2F28%2F20180428114906_ulvqd.jpg&refer=http%3A%2F%2Fb-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499575&t=76a0121a86d347aee89b82f99f717fe2',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fcdn.duitang.com%2Fuploads%2Fitem%2F201303%2F29%2F20130329205806_kTTnv.thumb.700_0.jpeg&refer=http%3A%2F%2Fcdn.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499576&t=9e767cd24fec55f9d7daff9831597804',
  'https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/zhidao/pic/item/9345d688d43f87948c83d520d21b0ef41bd53abb.jpg',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.nipic.com%2F2008-08-11%2F200881191132365_2.jpg&refer=http%3A%2F%2Fpic1.nipic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499977&t=882b6f6351660b52ba98ab99e8b66c35',
  'https://img2.baidu.com/it/u=2625258657,1445049083&fm=26&fmt=auto&gp=0.jpg',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fphotoblog%2F1108%2F09%2Fc5%2F8597586_8597586_1312885301234_mthumb.jpg&refer=http%3A%2F%2Fimg.pconline.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499991&t=34ca58622b41014aeb21c62937845807',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fbig5.wallcoo.com%2Fphotograph%2Fcandle_light_1920x1200%2Fimages%2Fcandle_Candle_light_4020.jpg&refer=http%3A%2F%2Fbig5.wallcoo.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499991&t=931b6190f9cfb63cadfff1477dbafbc6',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg13.3lian.com%2Fedu201310%2Fphotoshop%2Fp101%2F201310%2Fc7c4c33397aecad5ee7233f42a6e055c.jpg&refer=http%3A%2F%2Fimg13.3lian.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499990&t=576b0b889bbd64376dddf404b7145946',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2F1812.img.pp.sohu.com.cn%2Fimages%2Fblog%2F2009%2F11%2F18%2F18%2F8%2F125b6560a6ag214.jpg&refer=http%3A%2F%2F1812.img.pp.sohu.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499990&t=65f27179a550f80adff91a2e4941ca7d',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fphotoblog%2F1303%2F26%2Fc14%2F19263745_19263745_1364309047551_mthumb.jpg&refer=http%3A%2F%2Fimg.pconline.com.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499990&t=77c26bc7e666ce5ccf28598b16b69a0f',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi3.sinaimg.cn%2FIT%2F2012%2F0523%2FU2727P2DT20120523074847.jpg&refer=http%3A%2F%2Fi3.sinaimg.cn&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499990&t=316aaec88a41047672da5704ea75400d',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic7.nipic.com%2F20100520%2F2431632_001458008911_2.jpg&refer=http%3A%2F%2Fpic7.nipic.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628499990&t=014536cfa3a2ef3390a05f94173f7a68',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic.baike.soso.com%2Fp%2F20131111%2F20131111101600-1977413104.jpg&refer=http%3A%2F%2Fpic.baike.soso.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=4f3da16217047fd4776ac7a8d3a9c868',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fitem%2F201907%2F14%2F20190714181245_trysy.thumb.400_0.jpg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=a162fdea0c19bcd0af29382253c2bc05',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpicture.ik123.com%2Fuploads%2Fallimg%2F151231%2F3-151231143940.jpg&refer=http%3A%2F%2Fpicture.ik123.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=709eb8ca8bb568401950cefa89a47ecf',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimage1.nphoto.net%2Fnews%2Fimage%2F201201%2F35ca079b6e7babad.jpg&refer=http%3A%2F%2Fimage1.nphoto.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=485fe32298901961e691b2e8ec4e7e8f',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi9.download.fd.pchome.net%2Ft_960x600%2Fg1%2FM00%2F0B%2F1D%2FoYYBAFQ-ChqIYrGUABEvrz-DUBAAACASwNeo-0AES_H334.jpg&refer=http%3A%2F%2Fi9.download.fd.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=39305e24664334ec48dbd35eaca1061b',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F42%2F37%2F59%2Fpic_lib%2Fs960x639%2FAutumn_Wallpaper_%2835%29s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=4c58759afe3dc84da13dbea2f677d2cc',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F27%2F30%2F50%2Fpic_lib%2Fs960x639%2FPCHOMEdwzr1224qx09s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=3e191747620349d7a3f06d58879f2914',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fpic1.zhimg.com%2Fv2-04c3c9fc5a9b0bea9d02c5dbac41d075_1200x500.jpg&refer=http%3A%2F%2Fpic1.zhimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=4493609b54a9516e29c15868cef6eda2',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F33%2F96%2F09%2Fpic_lib%2Fs960x639%2Fpeople_nature_25s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=b9a176f033c792f76127190f8833a933',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F34%2F09%2F06%2Fpic_lib%2Fs960x639%2Fjmfj061s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=f47c9e091e2dba48a0a68a799fcc1ae4',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.juimg.com%2Ftuku%2Fyulantu%2F120712%2F201722-120G219163525.jpg&refer=http%3A%2F%2Fimg.juimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=beff200dce142b828594dbd3cd07a708',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F24%2F13%2F24%2Fpic_lib%2Fs960x639%2F010s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=ffd150185b8d7923580d8d83ec22c901',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fhbimg.b0.upaiyun.com%2Fe1f8a492d49c81fd9f449018f4ad74db069fd4f21433f-aW0U1z_fw658&refer=http%3A%2F%2Fhbimg.b0.upaiyun.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=d3d2e4cda690d0bec468b0b10a24d904',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.ph.126.net%2F8RU2gc3au2g2s6ZUU30iEg%3D%3D%2F1092122909654267255.jpg&refer=http%3A%2F%2Fimg.ph.126.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=9c8dbaba6c13706219a0b67f83e22a1b',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F31%2F49%2F81%2Fpic_lib%2Fs960x639%2FDaziran_15s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=cc544690fba8004688f8fcad3cf16641',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F42%2F17%2F99%2Fpic_lib%2Fs960x639%2Fzrfj%2520%2864%29s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=84da22007f06bffa8f37645802b0cabc',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F39%2F76%2F73%2Fpic_lib%2Fs960x639%2Fcoolfg20081128_003s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=81072badd64564453304183a9ad0188f',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F24%2F97%2F12%2Fpic_lib%2Fs960x639%2F002-land016s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=4049fc986f426bf678ecd9d794349ad2',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F24%2F68%2F10%2Fpic_lib%2Fs960x639%2Fjphaian028s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=ce9ba3f623a6c0e917b908bac076ea8d',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fupload-images.jianshu.io%2Fupload_images%2F2129923-8862de77cd5e3dd4.jpg&refer=http%3A%2F%2Fupload-images.jianshu.io&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=95edbf9799db8747ea53209587e7f9c6',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F25%2F67%2F38%2Fpic_lib%2Fs960x639%2F1600green_1034s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=57e4b6a55cd981e05bcd75a0166bac3c',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F37%2F91%2F06%2Fpic_lib%2Fs960x639%2FDaziran05s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=68f2932910e2043b9b69084436e8325b',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi2.3conline.com%2Fimages%2Fpiclib%2F201202%2F20%2Fbatch%2F1%2F126862%2F1329670593611crqg7tz3ul_medium.jpg&refer=http%3A%2F%2Fi2.3conline.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=ad24daaefa1d6ee50084b98cbdaec5e4',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F38%2F31%2F70%2Fpic_lib%2Fs960x639%2FHaitan47s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=3f8c4cd81159bdafbf9af012fd777bc7',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F27%2F08%2F70%2Fpic_lib%2Fs960x639%2F040s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=60356dc3f71a025f65474da53d7d795c',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimages.ali213.net%2Fpicfile%2Fpic%2F2013%2F03%2F28%2F927_wmf%2520%289%29.jpg&refer=http%3A%2F%2Fimages.ali213.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=2871cc19a72bb9b541315eb4eddc539e',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F31%2F94%2F27%2Fpic_lib%2Fs960x639%2FGreen%2520Rock%2520by%2520Masterchief%25201920_1200s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=e8bb184f3580a63fb204ea87e03fa1fa',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F28%2F02%2F47%2Fpic_lib%2Fs960x639%2FWebshot_08s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=07d9eb52e2fdce03448ab2e09cfe873e',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fq_70%2Cc_zoom%2Cw_640%2Fimages%2F20171228%2F8aed0c72f49546d88d6e78834d4a2643.jpeg&refer=http%3A%2F%2F5b0988e595225.cdn.sohucs.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=bdef3f3d116cc044ce5128ae717b21f4',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Finews.gtimg.com%2Fnewsapp_match%2F0%2F10874456092%2F0.jpg&refer=http%3A%2F%2Finews.gtimg.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=35cefb80f846bbb174eb78036e55ae28',
  'https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fimg.article.pchome.net%2F00%2F34%2F93%2F87%2Fpic_lib%2Fs960x639%2F1224168948521pdv3yaqtx8s960x639.jpg&refer=http%3A%2F%2Fimg.article.pchome.net&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1628500108&t=320073f0c77c17a1706062aa70f2e81c',
];
























