import 'dart:io';

import 'package:flutter/material.dart';

class PhotoMessageViewPage extends StatelessWidget {
  final TextEditingController messageController;
  final String path;
  final void Function() callback;

  PhotoMessageViewPage(
    this.messageController,
    this.path,
    this.callback,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white,
          /*
          actions: [
            IconButton(
                icon: Icon(
                  Icons.crop_rotate,
                  size: 27,
                ),
                onPressed: () {}),
            IconButton(
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  size: 27,
                ),
                onPressed: () {}),
            IconButton(
                icon: Icon(
                  Icons.title,
                  size: 27,
                ),
                onPressed: () {}),
            IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 27,
                ),
                onPressed: () {}),
          ],
          */
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child: Image.file(
                  File(path),
                  //fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  color: Colors.black38,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          child: TextField(
                            controller: messageController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                hintText: "Write message...",
                                hintStyle: TextStyle(color: Colors.black),
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      FloatingActionButton(
                        heroTag: "btn2",
                        onPressed: () {
                          callback();
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        backgroundColor: Colors.blue,
                        elevation: 0,
                      ),
                    ],
                  ),
                ),
              )
            ])));
  }
}


/*


Widget renderImage(singleMessage, context) {
  if (singleMessage!.imageUrl != null) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Hero(
          tag: singleMessage!.createdAt,
          child: Image.network(
            singleMessage!.imageUrl.toString(),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return DetailScreen(singleMessage!);
        }));
      },
    );
  } else {
    return Container();
  }
}

Widget renderMessage(singleMessage) {
  if (singleMessage!.message != null && singleMessage!.message!.isNotEmpty)
    return Text(singleMessage!.message.toString(),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
        ));
  else
    return Container();
}

Widget renderFile(singleMessage, context) {
  if (singleMessage!.fileUrl != null)
    return GestureDetector(
      child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Row(children: <Widget>[
            Hero(
              tag: singleMessage!.createdAt,
              child: Image.network(
                "https://findicons.com/files/icons/1579/devine/256/file.png",
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Flexible(child: Text('file PDF')),
          ])),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return DetailPdf(singleMessage!.fileUrl);
        }));
      },
    );
  else
    return Container();
}


*/