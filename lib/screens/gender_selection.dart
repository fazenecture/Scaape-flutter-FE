import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scaape/screens/homePage.dart';
import 'package:http/http.dart';
class GenderSelectionPage extends StatefulWidget {
  static String id = 'genderSelectionPage';
  @override
  _GenderSelectionPageState createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {

  Map<String, bool> genderSelected = {
    'Male': false,
    'Female': false,
    'Transgender': false,
    'Non-Binary': false,
    'Intersex': false,
  };
  TextEditingController controller = TextEditingController() ;
  DateTime selectedDate = DateTime.now();

  String getGender() {
    for(String gender in genderSelected.keys) {
      if(genderSelected[gender] ?? false) {
        return gender;
      }
    }
    if(controller.text.isNotEmpty) {
      return controller.text ;
    }
    return '' ;
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<IconData> genderIcons = [
    FontAwesomeIcons.mars,
    FontAwesomeIcons.venus,
    FontAwesomeIcons.transgenderAlt,
    FontAwesomeIcons.mercury,
    FontAwesomeIcons.transgender,
  ];

  Widget getGenderSelector(
      {required BuildContext context,
      required String title,
      required IconData icon,
      required bool? isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (var keys in genderSelected.keys) {
            if(keys != title) {
              genderSelected[keys] = false;
            }
          }
          genderSelected[title] = !(genderSelected[title] ?? true);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        height: MediaQuery.of(context).size.height * 0.065,
        width: MediaQuery.of(context).size.width * 0.70,
        decoration: BoxDecoration(
            color: Color(0xFF393E46),
            borderRadius: BorderRadius.circular(12),
            border: (isSelected ?? false)
                ? Border.all(color: Color(0xFFFF4265))
                : null),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 15),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signInData=ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                      text: 'To ',
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: 'Scaape!',
                          style: TextStyle(
                            fontSize: 32,
                            color: Color(0xFFFF4265),
                          ),
                        )
                      ]),
                ),
                Text(
                  'We should connect and to connect',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  'we must know each other!',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(
                  height: 30,
                ),
                RichText(
                  text: TextSpan(
                    text: 'What ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: 'Gender ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFF4265),
                        ),
                      ),
                      TextSpan(
                        text: 'do you',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                  'identify as?',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(
                  height: 30,
                ),
                ...[
                  for (int i = 0; i < genderIcons.length; i++)
                    Column(
                      children: [
                        getGenderSelector(
                          context: context,
                          title: genderSelected.keys.elementAt(i),
                          icon: genderIcons[i],
                          isSelected:
                              genderSelected[genderSelected.keys.elementAt(i)],
                        ),
                        SizedBox(height: 20)
                      ],
                    ),
                ],
                Container(
                  width: MediaQuery.of(context).size.width * 0.70,
                  child: TextField(
                    controller: controller,
                      decoration: InputDecoration(
                        // border: InputBorder.none,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0x00000000))
                        ),
                        fillColor: Color(0xFF393E46),
                        filled: true,
                        hintText: 'If not specified, please type down',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFFF4265), width: 2.0),
                        ),
                      )
                  ),
                ),
                SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    text: 'When\'s your ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: 'Birthday ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFF4265),
                        ),
                      ),
                      TextSpan(
                        text: '?!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFF393E46),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 20,),
                      IconButton(onPressed: () => _selectDate(context), icon: Icon(FontAwesomeIcons.calendarAlt))
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0x3BFF4265)
                          ),
                          child: Center(
                            child: Icon(Icons.arrow_back_ios),
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),
                      GestureDetector(
                        onTap: () async{
                          print((selectedDate.toString()).substring(0,9));
                          String url='http://65.0.121.93: 4000/api/createUser';
                          Map<String,String> headers={"Content-type":"application/json"};
                          //String json='{"UserId": "${signInData['UUID']}","EmailId": "${signInData['Email']}","BirthDate": "783783","Gender": "${getGender()}","Name": "${signInData['Name']}","ProfileImg": "${signInData['ProfileImage']}","InstaId": "sgvsed","Vaccine": true}';
                          String json='{"UserId": "3","EmailId": "4","BirthDate": "783783","Gender": "sdf","Name": "dgdg","ProfileImg": "dfgd","InstaId": "sgvsed","Vaccine": true}';
                          Response response=await put(Uri.parse(url),headers:headers,body:json);
                          //print(user.displayName);
                          int statusCode = response.statusCode;
                          print(statusCode);
                          print(response.body);
                          //TODO: Add images and instagram page

                          Navigator.pushNamed(context,HomePageView.id) ;
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFFFF4265)
                          ),
                          child: Center(
                            child: Text('Next', style: TextStyle(fontSize: 20),),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
