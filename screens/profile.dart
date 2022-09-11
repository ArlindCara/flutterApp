import 'package:flutter/material.dart';
import 'package:my_app/screens/editProfile.dart';
import 'package:my_app/screens/splashScreen.dart';
import 'package:my_app/utils/firebaseUtils.dart';
import 'package:my_app/utils/userInfos.dart';
import 'package:my_app/widgets/ProfilePictureWidget.dart';
import 'package:my_app/widgets/appBarWidget.dart';

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Profile();
  }
}

class _Profile extends State<Profile> {
  bool loaded = false;

  FirebaseUtils fbUtils = FirebaseUtils();

  late String nickname;
  late String about;

  @override
  void initState() {
    super.initState();
    getUsersInfo();
  }

  void getUsersInfo() async {
    UserInfos user = await fbUtils.retrieveUserDataFirebase();

    setState(() {
      nickname = user.nickname;
      about = user.about;
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: loaded == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              //if loading true circular loader
              //else quello che c'era,
              physics: BouncingScrollPhysics(),

              children: [
                ProfilePictureWidget(
                  //imagePath: user.imagePath,
                  onClicked: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => EditProfileScreen()),
                    );
                    setState(() {
                      getUsersInfo();
                    });
                  },
                ),
                const SizedBox(height: 60),
                renderUserName(),
                const SizedBox(height: 90),
                renderUserAbout(),
                const SizedBox(height: 60),
                TextButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black12),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                      ),
                    ),
                    onPressed: () async {
                      print('----');
                      if (await fbUtils.logoutGoogle() == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SplashScreen()),
                        );
                      }
                      setState(() {});
                    },
                    child: Text('Logout'))
              ],
            ),
    );
  }

  Widget renderUserName() => Column(
        children: [
          Text(
            //user.name.toString(),
            nickname,

            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 10),
          /*
          Text(
            email,
            style: TextStyle(color: Colors.grey),
          ),
          */
          const SizedBox(height: 43),
        ],
      );

  Widget renderUserAbout() => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              about,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}




//show nickname e aboutUS

//creare dati per messaggi
// collection messages, contiene tutti i messaggi scambiati
// quando scrivi un messaggio crei un nuovo messaggioù// che avrà sender ID e receiver ID
// il messaggio ha il sender ID e ma ha un chatRoom ID
// chatRoom ID generato come una stringa che è data dai 2 ID degli utenti
// ID chatroom -> array con ID degli utenti che partecipano alla chat
// classe messagge ID sender-ID receiver