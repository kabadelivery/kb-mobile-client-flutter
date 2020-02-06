import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kaba_flutter/src/contracts/login_contract.dart';
import 'package:kaba_flutter/src/models/AdModel.dart';
import 'package:kaba_flutter/src/utils/functions/Utils.dart';
import 'package:photo_view/photo_view.dart';
//import 'package:photo_view/photo_view.dart';


class ImagesPreviewPage extends StatefulWidget {

  static var routeName = "/ImagesPreviewPage";

  LoginPresenter presenter;

  /* list of ads */
  List<AdModel> data;

  ImagesPreviewPage({Key key, this.data}) : super(key: key);


  @override
  _ImagesPreviewPageState createState() => _ImagesPreviewPageState();
}

class _ImagesPreviewPageState extends State<ImagesPreviewPage> {

  int _carousselPageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: SizedBox(
              height: 25,
              width: 25,
              child: IconButton(icon: Icon(Icons.close, color: Colors.white))), onPressed: (){Navigator.pop(context);}),
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Center(
              child: Container(
                // center a picture thing in the middle
                child:   Stack(
                  children: <Widget>[
                    ClipPath(
                        child:CarouselSlider(
                          onPageChanged: _carousselPageChanged,
                          viewportFraction: 1.0,
//                      autoPlay: widget.data.length > 1 ? true:false,
                          enableInfiniteScroll: widget.data.length > 1 ? true:false,
                          height:  MediaQuery.of(context).size.width,
                          items: widget.data.map((admodel) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
//                                    height: 9*MediaQuery.of(context).size.width/16,
                                    height: MediaQuery.of(context).size.width,
                                    width: MediaQuery.of(context).size.width,
                                    child:CachedNetworkImage(
                                        imageUrl: Utils.inflateLink(admodel.pic),
                                        fit: BoxFit.contain
                                    )
//                                    child: PhotoView(
//                                      imageProvider: NetworkImage(Utils.inflateLink(admodel.pic), scale: 1.0),
//                                    )
                                );
                              },
                            );
                          }).toList(),
                        )),
                    Positioned(
                        bottom: 10,
                        right:0,
                        child:Padding(
                          padding: const EdgeInsets.only(right:9.0),
                          child: Row(
                            children: <Widget>[]
                              ..addAll(
                                  List<Widget>.generate(widget.data.length, (int index) {
                                    return Container(
                                        margin: EdgeInsets.only(right:2.5, top: 2.5),
                                        height: 9,width:9,
                                        decoration: new BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                                            border: new Border.all(color: Colors.white),
                                            color: (index==_carousselPageIndex || index==widget.data.length)?Colors.white : Colors.transparent
                                        ));
                                  })
                                /* add a list of rounded views */
                              ),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ),
            Positioned(top: 0,right: 10,
                child: OutlineButton(onPressed: () {  }, color: Colors.transparent, borderSide: BorderSide(color: Colors.white, width: 1),
                child: Text(_getVoirMenuTextFromAd(widget.data[_carousselPageIndex]), style: TextStyle(color: Colors.white)))
            ),
            Positioned(
                bottom: 10,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.all(4),
                      child: Text(widget.data[_carousselPageIndex]?.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 7,
                          style: TextStyle(color: Colors.white))),
                )
            )
          ],
        ));
  }

  _carousselPageChanged(int index) {
    setState(() {
      _carousselPageIndex = index;
    });
  }

  String _getVoirMenuTextFromAd(AdModel data) {

  }

}
