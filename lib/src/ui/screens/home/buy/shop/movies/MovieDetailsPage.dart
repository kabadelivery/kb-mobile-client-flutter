import 'package:KABA/src/contracts/movie_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/MovieModel.dart';
import 'package:KABA/src/models/ShopModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MovieDetailsPage extends StatefulWidget {
  MovieModel movie = MovieModel(
      id: 3,
      movie_type: "Adventure, Fiction, Thrilling",
      name: "Last of us",
      pic:
          "https://image.api.playstation.com/vulcan/img/rnd/202011/1020/FKgazVvG7BcWouCr39mIiXkW.png",
      description:
          "The Last of Us, est le nom d'une série de jeux vidéo, développée par Naughty Dog et éditée par Sony Computer Entertainment, de type action-aventure et survie, ayant comme thème principal un univers post-apocalyptique après une pandémie provoquée par un champignon appelé le cordyceps.",
      age_limit: "17+");

  MoviePresenter presenter;

  MovieDetailsPage({this.movie, this.presenter});

  @override
  State<StatefulWidget> createState() {
    return MovieDetailsPageState();
  }
}

class MovieDetailsPageState extends State<MovieDetailsPage>
    implements MovieView {
  int DESCRIPTION_MAX_CHAR_LENGTH = 200;

  bool descriptionIsShorted = true;

  @override
  void initState() {
    super.initState();
    widget.presenter.movieView = this;
  }

  @override
  Widget build(BuildContext context) {
    widget.movie = MovieModel(
        id: 3,
        movie_type: "Adventure, Fiction, Thrilling",
        name: "Last of us",
        pic:
            "https://image.api.playstation.com/vulcan/img/rnd/202011/1020/FKgazVvG7BcWouCr39mIiXkW.png",
        description:
            "The Last of Us, est le nom d'une série de jeux vidéo, développée par Naughty Dog et éditée par Sony Computer Entertainment, de type action-aventure et survie, ayant comme thème principal un univers post-apocalyptique après une pandémie provoquée par un champignon appelé le cordyceps.",
        age_limit: "17+");
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
          brightness: Brightness.light,
          backgroundColor: KColors.primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context).translate('movie_details')}"),
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
        body: Container(
            padding: EdgeInsets.only(right: 10, left: 10),
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Center(
                      child: Expanded(
                        child: Container(
                            height: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3)),
                                border: new Border.all(
                                    color: KColors.primaryYellowColor
                                        .withOpacity(0.3),
                                    width: 3),
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                        // Utils.inflateLink(movie?.pic)
                                        widget?.movie?.pic)))),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("${widget?.movie?.name}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: KColors.new_black)),
                    SizedBox(height: 3),
                    Text("${widget?.movie?.movie_type}",
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: KColors.new_black,
                            fontSize: 10)),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: () => {
                        setState(() =>
                            {descriptionIsShorted = !descriptionIsShorted})
                      },
                      child: RichText(
                        text: TextSpan(
                            text:
                                "${_cutShortedDescription(widget?.movie?.description, descriptionIsShorted)}",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                                fontSize: 12),
                            children: [
                              TextSpan(
                                  text: (descriptionIsShorted &&
                                          widget?.movie?.description?.length >
                                              DESCRIPTION_MAX_CHAR_LENGTH)
                                      ? "  ${AppLocalizations.of(context).translate("see_more")}"
                                      : "",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: KColors.mBlue.withAlpha(150)))
                            ]),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Container(
                            child: Text("${widget?.movie?.age_limit}",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            padding: EdgeInsets.only(
                                left: 8, right: 8, top: 3, bottom: 3),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5)),
                                color: KColors.primaryColor.withOpacity(0.15))),
                        SizedBox(
                          width: 10,
                        ),   Container(
                            child: Text("${widget?.movie?.age_limit}",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            padding: EdgeInsets.only(
                                left: 8, right: 8, top: 3, bottom: 3),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5)),
                                color: KColors.primaryColor.withOpacity(0.15))),
                        SizedBox(
                          width: 10,
                        ),   Container(
                            child: Text("${widget?.movie?.age_limit}",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            padding: EdgeInsets.only(
                                left: 8, right: 8, top: 3, bottom: 3),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5)),
                                color: KColors.primaryColor.withOpacity(0.15))),
                        SizedBox(
                          width: 10,
                        ),   Container(
                            child: Text("${widget?.movie?.age_limit}",
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            padding: EdgeInsets.only(
                                left: 8, right: 8, top: 3, bottom: 3),
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.all(Radius.circular(5)),
                                color: KColors.primaryColor.withOpacity(0.15))),
                        SizedBox(
                          width: 10,
                        ),
                        // Text("${movie?.}")
                        // we should tell if a language is allowed or not
                      ],
                    )
                  ]),
            )));
  }

  @override
  void inflateMovieSchedule(ShopModel Movie, List<MovieModel> data) {}

  @override
  void networkError() {
    // TODO: implement networkError
  }

  @override
  void showLoading(bool isLoading) {
    // TODO: implement showLoading
  }

  @override
  void systemError() {
    // TODO: implement systemError
  }

  _cutShortedDescription(String description, bool descriptionIsShorted) {
    if (descriptionIsShorted &&
        description?.length > DESCRIPTION_MAX_CHAR_LENGTH)
      return description?.substring(0, DESCRIPTION_MAX_CHAR_LENGTH) + "...";
    else
      return description;
  }
}
