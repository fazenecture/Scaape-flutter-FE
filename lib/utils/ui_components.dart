import 'package:flutter/material.dart';

import 'constants.dart';

class SearchBoxContainer extends StatelessWidget {
  const SearchBoxContainer({
    Key? key,
    required this.medq,
  }) : super(key: key);

  final double medq;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23.0),
          color: const Color(0xff393e46),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0a000000),
              offset: Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 8, top: 5),
          child: TextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Looking for someone or something.....',
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: medq * 0.018,
                  color: const Color(0x5cffffff),
                  fontWeight: FontWeight.w400,
                ),
                suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.search,
                      color: Color(0x5cffffff),
                    ))),
          ),
        ),
      ),
    );
  }
}

class HomeButtons extends StatelessWidget {
  const HomeButtons({
    Key? key,
    required this.medq,
    required this.buttontext,
    required this.icon,
    required this.img,
  }) : super(key: key);

  final double medq;
  final IconData icon;
  final String buttontext;
  final Image img;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        gradient: LinearGradient(
          begin: Alignment(0.0, -1.0),
          end: Alignment(0.0, 1.0),
          colors: [const Color(0x24ff416c), const Color(0x24ff4b2b)],
          stops: [0.0, 1.0],
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10.0, right: 10, top: 8, bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon,
                size: 20,
                color: ScaapeTheme.kPinkColor,
              ),
              // child: Image.asset(
              //   imgsrc,
              //   height: 25,
              //   width: 25,
              //   fit: BoxFit.fill,
              // ),
            ),
            Text(
              buttontext,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: medq * 0.02,
                color: ScaapeTheme.kPinkColor,
              ),
              textAlign: TextAlign.left,
            )
          ],
        ),
      ),
    );
  }
}

class TrendingCards extends StatelessWidget {
  const TrendingCards(
      {Key? key,
      required this.imageUrl,
      required this.medq,
      required this.description,
      required this.title})
      : super(key: key);
  final String imageUrl;
  final Size medq;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: medq.width * 0.94,
        height: medq.height * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [Color(0xff393E46), Colors.transparent]),
          // image: DecorationImage(
          //   colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          //   image: NetworkImage(imageUrl),
          //   fit: BoxFit.fill,
          // ),
        ),
        child: Stack(children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            width: medq.width * 0.94,
            height: medq.height * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(imageUrl),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            width: medq.width * 0.94,
            height: medq.height * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff393E46),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  Color(0xFFFF4B2B).withOpacity(0.5),
                              child: CircleAvatar(
                                backgroundImage:
                                    AssetImage('images/profile-photo.jpg'),
                                backgroundColor: Colors.transparent,
                                radius: 25,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Dhriti Sharma',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Image.asset(
                                      'images/tick.png',
                                      height: 20,
                                      width: 20,
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 17,
                                    ),
                                    Text(
                                      'Delhi, India',
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                        color: const Color(0xfff5f6f9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        ImageIcon(AssetImage('images/tripledot.png'))
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: medq.height * 0.035,
                            color: const Color(0xffffffff),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: medq.height * 0.02,
                              color: const Color(0xfff5f6f9),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        // Text(
                        //   username,
                        //   style: TextStyle(
                        //     fontFamily: 'Roboto',
                        //     fontSize: medq * 0.018,
                        //     color: const Color(0xffffffff),
                        //     fontWeight: FontWeight.w400,
                        //   ),
                        //   textAlign: TextAlign.left,
                        // )
                      ],
                    ),
                  ],
                ),
                Image.asset(
                  'images/join-icon.png',
                  height: 30,
                  width: 30,
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}

