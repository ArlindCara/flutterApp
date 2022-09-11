import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_app/models/message.dart';
import 'package:my_app/utils/loginRegisterData.dart';
import 'package:my_app/utils/userInfos.dart';

class FirebaseUtils {
  static final FirebaseUtils _singleton = FirebaseUtils._internal();

  factory FirebaseUtils() => _singleton;
  FirebaseUtils._internal();

  // arlc@gmail.com
  // 1q2w3e4r

  Future<LoginRegisterData> signInLocal(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    String? error;
    bool logged = false;

    try {
      print('0----------');
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('1---------- $userCredential');

      user = userCredential.user;

      String currentPushToken =
          await FirebaseMessaging.instance.getToken() as String;

      UserInfos currentUser = await retrieveUserDataFirebase();

      if (!currentUser.pushTokens.contains(currentPushToken)) {
        FirebaseMessaging.instance.getToken().then((token) {
          print('token: $token');
          FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
            'pushToken': FieldValue.arrayUnion(['$token'])
          });
        }).catchError((err) {
          print('errore token');
        });
      }

      logged = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
        print('No user found for that email.');
        //showAlertDialog(context, error);
      } else if (e.code == 'wrong-password') {
        error = 'Wrong password provided for that user.';
        print('Wrong password provided for that user.');
        //showAlertDialog(context, error);
      }
    }
    LoginRegisterData loggedUser =
        LoginRegisterData(userCredential: logged, error: error);
    return loggedUser;
  }

  Future<LoginRegisterData> registerLocal(String email, String password) async {
    User? user;

    bool registered = false;
    String? error;
    // arlc@gmail.com
    // 1q2w3e4r

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      user = userCredential.user;
      print('user1234: ${user!.uid}');

      String currentPushToken =
          await FirebaseMessaging.instance.getToken() as String;

      //UserInfos currentUser = await retrieveUserDataFirebase();

      UserInfos currUser = new UserInfos(
          id: userCredential.user!.uid,
          nickname: userCredential.user!.email as String,
          about: '',
          pushTokens: []);
      FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nickname': currUser.nickname,
        'id': currUser.id,
        'about': '',
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'pushToken': FieldValue.arrayUnion(
          ['$currentPushToken'],
        )
      });

      /*
        FirebaseMessaging.instance.getToken().then((token) {
          print('token: $token');
          FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
            'pushToken': FieldValue.arrayUnion(['$token'])
          });
        }).catchError((err) {
          print('errore token');
        });
        */

      registered = true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        error = 'Your email address appears to be malformed.';
        print('The password provided is too weak.');
        //showAlertDialog(context, error);
      } else if (e.code == 'weak-password') {
        error = 'The password provided is too weak.';
        print('The password provided is too weak.');
        //showAlertDialog(context, error);
      } else if (e.code == 'email-already-in-use') {
        error = 'The account already exists for that email.';
        print('The account already exists for that email.');
        //showAlertDialog(context, error);
      }
    } catch (e) {
      print(e);
    }
    LoginRegisterData registeredUser =
        LoginRegisterData(userCredential: registered, error: error);
    return registeredUser;
  }

  // Before: Future<bool> signInWithGoogle(context) async
  Future<bool> signInWithGoogle() async {
    // Trigger the authentication flow

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      print('null google');
      return false;
    }
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    User? firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;
    if (firebaseUser == null) {
      return false;
    }

    await FirebaseAuth.instance.signInWithCredential(credential);
    UserInfos currUser = new UserInfos(
        id: firebaseUser.uid,
        nickname: firebaseUser.displayName.toString(),
        about: '',
        pushTokens: []);

    // prima del set
    //verifico che non ci sia già quel utente sul firesotre
    //(all'intenro della collection con quell id, se c'è è già registrato,
    //prendere i suoi dati
    //altrimenti inizializzo i dati vuoti
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where("id", isEqualTo: firebaseUser.uid)
        .get();

    if (result.docs.isEmpty) {
      print('entrato crea');

      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'nickname': currUser.nickname,
        'id': currUser.id,
        'about': currUser.about,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString()
      });
      return true;
    }

    // Once signed in, return the UserCredential
    print('entrato signIn');

    return true;
  }

  Future<List<UserInfos>> retrieveUsersListFirebase(
      TextEditingController searchBarController) async {
    // faccio sempre solo la prima query
    // scarico i dati del db e poi faccio una ricerca
    // su questo array di users
    //

    late QuerySnapshot result;
    if (searchBarController.text.isEmpty) {
      result = await FirebaseFirestore.instance.collection('users').get();
    } else if (searchBarController.text.isNotEmpty) {
      result = await FirebaseFirestore.instance
          .collection('users')
          .where("nickname", isEqualTo: searchBarController.text)
          .get();
    }

    final List<DocumentSnapshot> documents = result.docs;

    List<UserInfos> chatUsers = [];

    for (int i = 0; i < documents.length; i++) {
      UserInfos tmpUser = UserInfos.fromDocument(documents[i]);

      chatUsers.add(tmpUser);
    }

    return chatUsers;
  }

  Future<UserInfos> retrieveUserDataFirebase() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser!.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    String nickname = documents[0].get('nickname');
    String about = documents[0].get('about');
    List<dynamic> pushTokens = documents[0].get('pushToken');

    List<String> pushTokensFinal = [];
    for (int i = 0; i < pushTokens.length; i++) {
      pushTokensFinal.add(pushTokens[i] as String);
    }
    for (int i = 0; i < pushTokensFinal.length; i++) {
      print('- ${pushTokensFinal[i]}');
    }

    //String email = firebaseUser!.displayName.toString();
    UserInfos userFb = new UserInfos(
      id: documents[0].id,
      nickname: nickname,
      about: about,
      pushTokens: pushTokensFinal,
    );

    return userFb;
  }

  Future<void> updateNicknameAndAboutData(UserInfos user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'nickname': user.nickname,
      'about': user.about,
    });
  }

  Future<List<Message>> retrieveMessagesFirebase(String chattinWithUser) async {
    List<Message> messagesFirebase = [];
    int itemsPerPage = 20;

    String currUser = FirebaseAuth.instance.currentUser!.uid;

    String chatroomId = combineIds(currUser, chattinWithUser);

    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('messages')
        .where("chatroomId", isEqualTo: chatroomId)
        .orderBy('createdAt', descending: false)
        .limitToLast(itemsPerPage)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    for (int i = 0; i < documents.length; i++) {
      Message tmpMessage = Message.fromDocument(documents[i]);

      messagesFirebase.add(tmpMessage);
    }
    return messagesFirebase;
  }

  Future<List<Message>> retrieveMoreMessagesFirebase(
      userdata, firstCreatedAt) async {
    String currUser = FirebaseAuth.instance.currentUser!.uid;
    String chattinWithUser = userdata.id;

    String chatroomId = combineIds(currUser, chattinWithUser);

    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('messages')
        .where("chatroomId", isEqualTo: chatroomId)
        .orderBy('createdAt', descending: true)
        .startAfter([firstCreatedAt])
        .limit(5)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    List<Message> messagesTmp = [];

    for (int i = documents.length - 1; i >= 0; i--) {
      Message tmpMessage = Message.fromDocument(documents[i]);

      messagesTmp.add(tmpMessage);
    }
    return messagesTmp;
  }

  Future<List<Message>> retrieveContinuousMessages(
      userdata, lastCreatedAt) async {
    String currUser = FirebaseAuth.instance.currentUser!.uid;
    String chattinWithUser = userdata;

    String chatroomId = combineIds(currUser, chattinWithUser);
    List<Message> messagesTmp = [];

    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('messages')
        .where("chatroomId", isEqualTo: chatroomId)
        .orderBy('createdAt', descending: false)
        .startAfter([lastCreatedAt]).get();

    final List<DocumentSnapshot> documents = result.docs;

    for (int i = documents.length - 1; i >= 0; i--) {
      Message tmpMessage = Message.fromDocument(documents[i]);

      messagesTmp.add(tmpMessage);
    }

    return messagesTmp;
  }

  void sendMessage(messageController, userdata) async {
    print('entrato _sendMessage');
    String message = messageController.text;
    print(message);

    String chatroomIdFirebase =
        combineIds(FirebaseAuth.instance.currentUser!.uid, userdata.id);

    if (message.isNotEmpty) {
      Message textMessageToSend = Message(
        chatroomId: chatroomIdFirebase,
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: null,
        message: message,
        senderId: FirebaseAuth.instance.currentUser!.uid,
        fileUrl: null,
      );
      sendMessageFinal(textMessageToSend);
    }
  }

  void uploadImageFirebase(filePath, imageFile, userdata) async {
    //Future<void> uploadImage(String filePath) async {
    var ref = FirebaseStorage.instance.ref().child('images').child(filePath);

    var uploadTask = await ref.putFile(imageFile!);

    String imageUrl = await uploadTask.ref.getDownloadURL();

    print('url $imageUrl');
    String chatroomIdFirebase =
        combineIds(FirebaseAuth.instance.currentUser!.uid, userdata.id);

    Message imageToSend = Message(
      chatroomId: chatroomIdFirebase,
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: imageUrl,
      message: null,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      fileUrl: null,
    );

    //sendPhoto(imageUrl, userdata);
    sendMessageFinal(imageToSend);
  }

  void uploadFileFirebase(filePath, userdata) async {
    var ref = FirebaseStorage.instance
        .ref()
        .child('files')
        .child(filePath.toString());

    var uploadTask = await ref.putFile(filePath);

    String fileUrl = await uploadTask.ref.getDownloadURL();

    print('url $fileUrl');
    String chatroomIdFirebase =
        combineIds(FirebaseAuth.instance.currentUser!.uid, userdata.id);

    Message fileToSend = Message(
      chatroomId: chatroomIdFirebase,
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: null,
      message: null,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      fileUrl: fileUrl,
    );

    //sendPhoto(imageUrl, userdata);
    sendMessageFinal(fileToSend);
  }

  void uploadPhotoAndMessage(imageFile, String message, userdata) async {
    var ref = FirebaseStorage.instance
        .ref()
        .child('files')
        .child(imageFile.toString());

    var uploadTask = await ref.putFile(imageFile);

    String fileUrl = await uploadTask.ref.getDownloadURL();

    print('url $fileUrl');
    String chatroomIdFirebase =
        combineIds(FirebaseAuth.instance.currentUser!.uid, userdata.id);

    Message photoMessageToSend = Message(
      chatroomId: chatroomIdFirebase,
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: fileUrl,
      message: message,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      fileUrl: null,
    );

    //sendPhoto(imageUrl, userdata);
    sendMessageFinal(photoMessageToSend);
  }

  void sendMessageFinal(Message message) {
    FirebaseFirestore.instance.collection('messages').add({
      'chatroomId': message.chatroomId,
      'senderId': message.senderId,
      'createdAt': message.createdAt,
      'message': message.message,
      'imageUrl': message.imageUrl,
      'fileUrl': message.fileUrl,
    });
  }

  String combineIds(String currUser, String chatWith) {
    String chatroomId;

    if (currUser.compareTo(chatWith) != 1) {
      chatroomId = currUser + '-' + chatWith;
    } else {
      chatroomId = chatWith + '-' + currUser;
    }
    return chatroomId;
  }

  StreamSubscription<QuerySnapshot> updateMessages(
      String userdata,
      String lastCreatedAt,
      void Function(DocumentChangeType actionType, Message msg)
          callBackMessages) {
    String currUser = FirebaseAuth.instance.currentUser!.uid;
    String chattinWithUser = userdata;
    String chatroomId = combineIds(currUser, chattinWithUser);
    //List<Message> messagesTmp = [];

    // gestire casi add  e remove messagge

    StreamSubscription<QuerySnapshot> streamSubMsg = FirebaseFirestore.instance
        .collection("messages")
        .where("chatroomId", isEqualTo: chatroomId)
        .orderBy('createdAt', descending: false)
        .startAfter([lastCreatedAt])
        .snapshots()
        .listen((result) {
          result.docChanges.forEach((res) {
            if (res.type == DocumentChangeType.added &&
                res.doc.data() != null) {
              print("added");
              print(res.type);
              print(res.doc.data());
              String? message = res.doc.data()!['message'];
              String chatroomId = res.doc.data()!['chatroomId'];
              String senderId = res.doc.data()!['senderId'];
              String createdAt = res.doc.data()!['createdAt'];
              String? imageUrl = res.doc.data()!['imageUrl'];
              String? fileUrl = res.doc.data()!['fileUrl'];
              Message newMsg = Message(
                  chatroomId: chatroomId,
                  createdAt: createdAt,
                  message: message,
                  senderId: senderId,
                  imageUrl: imageUrl,
                  fileUrl: fileUrl);
              callBackMessages(res.type, newMsg);
            } else if (res.type == DocumentChangeType.modified &&
                res.doc.data() != null) {
              print("modified");
              print(res.doc.data());
              String? message = res.doc.data()!['message'];
              String chatroomId = res.doc.data()!['chatroomId'];
              String senderId = res.doc.data()!['senderId'];
              String createdAt = res.doc.data()!['createdAt'];
              String? imageUrl = res.doc.data()!['imageUrl'];
              String? fileUrl = res.doc.data()!['fileUrl'];
              Message newMsg = Message(
                chatroomId: chatroomId,
                createdAt: createdAt,
                message: message,
                senderId: senderId,
                imageUrl: imageUrl,
                fileUrl: fileUrl,
              );
              callBackMessages(res.type, newMsg);
            } else if (res.type == DocumentChangeType.removed &&
                res.doc.data() != null) {
              print("removed");
              print(res.doc.data());
              String? message = res.doc.data()!['message'];
              String chatroomId = res.doc.data()!['chatroomId'];
              String senderId = res.doc.data()!['senderId'];
              String createdAt = res.doc.data()!['createdAt'];
              String? imageUrl = res.doc.data()!['imageUrl'];
              String? fileUrl = res.doc.data()!['fileUrl'];
              Message newMsg = Message(
                chatroomId: chatroomId,
                createdAt: createdAt,
                message: message,
                senderId: senderId,
                imageUrl: imageUrl,
                fileUrl: fileUrl,
              );
              callBackMessages(res.type, newMsg);
            }
          });
        });

    return streamSubMsg;
    //passare callback: chiamata ogni volta che c'è modifica
    //lista messaggi, ogni volta chiamo callback
    //che aggiorna la lista
    //calback(tipo evento (del, add, modify), messagge)
    //
  }

  Future<bool> logoutGoogle() async {
    /*
    final googleSignIn = GoogleSignIn();

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();
    */
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;

    String pushToken = await FirebaseMessaging.instance.getToken() as String;

    user = auth.currentUser;
    await FirebaseAuth.instance.signOut();
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'pushToken': FieldValue.arrayRemove([pushToken])
    });
    return true;
  }
}

/*

1) lista utenti array a cui mandare Messaggio

2) lista pushToken nel DB se ci sono più dispositivi

3) eliminare pushToken quando logOut


*/
