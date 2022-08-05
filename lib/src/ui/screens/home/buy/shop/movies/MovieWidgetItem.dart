import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/MovieModel.dart';
import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MovieWidgetItem extends StatelessWidget {
  MovieModel movie = MovieModel(
      id: 3,
      movie_type: "Adventure, Fiction, Thrilling",
      name: "Last of us",
      pic:
          "https://image.api.playstation.com/vulcan/img/rnd/202011/1020/FKgazVvG7BcWouCr39mIiXkW.png",
      description:
          "The Last of Us, est le nom d'une série de jeux vidéo, développée par Naughty Dog et éditée par Sony Computer Entertainment, de type action-aventure et survie, ayant comme thème principal un univers post-apocalyptique après une pandémie provoquée par un champignon appelé le cordyceps.",
      age_limit: "17+");

  Function jumpToMovieDetails;

  MovieWidgetItem({this.jumpToMovieDetails});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => jumpToMovieDetails(context, movie),
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 10),
        child: Row(
          children: [
            Container(
              height: 125,
              width: 90,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  border: new Border.all(
                      color: KColors.primaryYellowColor.withOpacity(0.3),
                      width: 3),
                  image: new DecorationImage(
                      fit: BoxFit.cover, image: CachedNetworkImageProvider(
                          // Utils.inflateLink(movie?.pic)
                          movie?.pic))
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 125,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${movie?.name}",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: KColors.new_black)),
                        SizedBox(height: 3),
                        Text("${movie?.movie_type}",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: KColors.new_black,
                                fontSize: 10)),
                        SizedBox(height: 5),
                        Text("${movie?.description}",
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                                fontSize: 11)),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                            child: Text("${movie?.age_limit}",
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
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
