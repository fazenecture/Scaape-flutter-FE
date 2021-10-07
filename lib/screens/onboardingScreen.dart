import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:lottie/lottie.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:scaape/screens/signIn_page.dart';

const kBackgroundColor = Color(0xFF22242C);
const kLightBlueColor = Color(0xFF393E46);
const kPinkColor = Color(0xFFFF4265);
const kOnBoardDesc = TextStyle(
    color: CupertinoColors.white, fontWeight: FontWeight.w400, fontSize: 14);



class OnBoarding extends StatefulWidget {
  static String id = 'Onboarding_screen';

  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final introKey = GlobalKey<IntroductionScreenState>();

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        bodyWidget: OnBoardRive(),
        title: '',
        // footer: Text('@asafadafad'),
      ),
      PageViewModel(
        bodyWidget: OnBoardLottie(
          whiteText: 'Find your',
          colouredText: 'Clubbies!',
          desc:
          'With our app show an interest in other people and try to open yourself up to a whole new experience because "Har ek friend zaroori hota hai" ;)' ,
          lottie: 'animations/find-clubbies.json',
        ),
        title: '',
        // footer: Text('@asafadafad'),
      ),
      PageViewModel(
        bodyWidget: OnBoardLottie(
          whiteText: 'And',
          colouredText: 'Scape!',
          desc:
          'Let\'s escape to Scaape, because In the end, we only regret the chances we didn’t take',
          lottie: 'animations/AndScaape.json',
        ),
        title: '',
        // footer: Text('@asafadafad'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: IntroductionScreen(
        key: introKey,
        onDone: () {
          //push to signup screen
          Navigator.pushReplacementNamed(context,SignInScreen.id);
        },
        pages: getPages(),
        globalBackgroundColor: kBackgroundColor,
        showNextButton: true,
        nextColor: kBackgroundColor,
        doneColor: kBackgroundColor,
        next: Hero(
          tag: 'onBoardButton',
          child: Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 23, vertical: 8),
              child: Text(
                'Next',
                style: TextStyle(color: CupertinoColors.white, fontSize: 14),
              ),
            ),
            color: kPinkColor,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(37)),
          ),
        ),
        done: Hero(
          tag: 'onBoardButton',
          child: Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 23, vertical: 8),
              child: Text(
                'Signup',
                style: TextStyle(color: CupertinoColors.white, fontSize: 14),
              ),
            ),
            color: kPinkColor,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(37)),
          ),
        ),
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        dotsFlex: 1,
        skip: Text(
          'Skip',
          style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400),
        ),
        showDoneButton: true,
        color: kPinkColor,
        dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(13.0, 6.0),
          activeColor: kPinkColor,
          color: kPinkColor.withOpacity(0.2),
          spacing: const EdgeInsets.symmetric(horizontal: 5.0),
          activeShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
      ),
    );
  }
}

// only for lottie animation
class OnBoardLottie extends StatelessWidget {
  const OnBoardLottie(
      {this.desc, this.colouredText, this.whiteText, this.lottie});

  final lottie;
  final whiteText;
  final colouredText;
  final desc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(
              10, MediaQuery.of(context).size.height * 0.2, 10, 10),
          height: 200,
          width: 200,
          color: kBackgroundColor,
          child: ClipOval(
            child: CircleAvatar(
              backgroundColor: kLightBlueColor,
              child: Lottie.asset(
                '$lottie',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.07,
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: '$whiteText ',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '$colouredText',
                style: TextStyle(
                  color: kPinkColor,
                  fontSize: 25,
                  // fontFamily: 'TheSecret',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 44),
          child: Text(
            '$desc',
            maxLines: 6,
            textAlign: TextAlign.center,
            style: kOnBoardDesc,
          ),
        ),
      ],
    );
  }
}

// only for rive animation
class OnBoardRive extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(
              10, MediaQuery.of(context).size.height * 0.2, 10, 10),
          height: 200,
          width: 200,
          color: kBackgroundColor,
          child: ClipOval(
            child: CircleAvatar(
              backgroundColor: kLightBlueColor,
              child: RiveAnimation.asset(
                'animations/handshake -on.riv',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.07,
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Hola ',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: 'Amigos!',
                style: TextStyle(
                  color: kPinkColor,
                  fontSize: 25,
                  // fontFamily: 'TheSecret',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 68),
          child: Text(
            'Nothing beats the warmth of a friend’s presence in our life.\nWelcome, buddy!',
            maxLines: 3,
            textAlign: TextAlign.center,
            style: kOnBoardDesc,
          ),
        ),
      ],
    );
  }
}
