import 'package:flutter/material.dart';

import 'package:my_app/utils/firebaseUtils.dart';
import 'package:my_app/utils/userInfos.dart';
import 'package:my_app/widgets/addNewUserButton.dart';
import 'package:my_app/widgets/usersList.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<HomePage> {
  final searchBarController = TextEditingController();
  final addUserController = TextEditingController();
  //List<ChatUsers> filteredChatUsers = [];
  FirebaseUtils fbUtils = FirebaseUtils();

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    searchBarController.addListener(showSearchedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Conversations",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    AddNewUserButton(
                      Icons.add,
                      "Add more",
                      addnewUserForm,
                      //color: Colors.red,
                    )
                  ],
                ),
              ),
            ),
            //SearchBar(),
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                controller: searchBarController,
                decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: EdgeInsets.all(8),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade100))),
              ),
            ),

            showUsersList(),
          ],
        ),
      ),
    );
  }

  Widget showUsersList() {
    return FutureBuilder<List<UserInfos>>(
        future: fbUtils.retrieveUsersListFirebase(searchBarController),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {}
          if (!snapshot.hasData) {
            return Center(child: Text('Loading'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 16),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return UsersList(
                userdata: snapshot.data![index],
              );
            },
          );
        });
  }

  void _addUser() {
    /*
    ChatUsers newUser = new ChatUsers(
        name: addUserController.text,
        messageText: "Ciao come va??",
        imageURL:
            "https://cdn.pixabay.com/photo/2020/07/01/12/58/icon-5359553_1280.png",
        time: "10 Aug");

    setState(() {
      if (addUserController.text.isNotEmpty) filteredChatUsers.add(newUser);
      addUserController.text = '';
    });
    */
  }

  void showSearchedItems() {
    //fare query mettendo come clausola
    //che il nome nel db contiene quello scritto  su search bar

    //var stringa della classe che cintiene attuale stringa di ricerca sincronizzata con editing text, la variabile si deve agggiornare(null o vuota)
    // aggiornanodic fa set state e parte il build della schermata
    //che richiana future builder e richiama get users
    // query where.name.contains
    //in pratica tutto nel setState

    print('Second text field: ${searchBarController.text}');

    setState(() {
      fbUtils.retrieveUsersListFirebase(searchBarController);
    });
  }

  void addnewUserForm() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text('Add User'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: addUserController,
                      decoration: InputDecoration(
                        labelText: 'Name & Surname',
                        icon: Icon(Icons.account_box),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  child: Text("Add User"),
                  onPressed: () {
                    Navigator.pop(context);
                    _addUser();
                  })
            ],
          );
        });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    searchBarController.dispose();
    super.dispose();
  }
}
