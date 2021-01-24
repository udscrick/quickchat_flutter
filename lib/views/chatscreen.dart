import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickchat/helpers/sharedpref_helper.dart';
import 'package:quickchat/services/database.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String uesrname;
  ChatScreen(this.name, this.uesrname);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatroomId, messageId="";
  Stream messageStream;
  String myName, myProfilePic, myEmail, myUserName;
  TextEditingController messagetextController = TextEditingController();

  getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myUserName = await SharedPreferenceHelper().getUserName();

    chatroomId = getChatRoomIdByUsernames(widget.uesrname, myUserName);
    print("Chat room id: "+chatroomId);
  }

  getChatRoomIdByUsernames(String a, String b) {
   
  int compareval1 = a.compareTo(b);
   int compareval2 = b.compareTo(a);
  if(compareval1>compareval2){
    return "$a\_$b";
  }
  else{
    return "$b\_$a";
  }
    // print('val 1: '+compareval1.toString());
     
    // print('val 2: '+compareval2.toString());
    // if (a.substring(0, 1).codeUnitAt(0) >= b.substring(0, 1).codeUnitAt(0)) {
    //   return "$b\_$a";
    // } else {
    //   return "$a\_$b";
    // }
  }

  addMessage(bool sendmsg) {
    print("Message: "+messagetextController.text);
    if (messagetextController.text != "") {
      String message = messagetextController.text;
      var lastMsgTimestamp = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMsgTimestamp,
        "imgurl": myProfilePic
      };

      //message id
      

      if (messageId == "") //If message is still being typed
      {
        messageId = randomAlphaNumeric(12);
          print("Message ID: "+messageId);
      }
 print("Message ID: "+messageId);

      DatabaseMethods()
          .addMessage(chatroomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendTs": lastMsgTimestamp,
          "lastMessageSendBy": myUserName
        };

        DatabaseMethods().updateLastMessageSent(chatroomId, lastMessageInfoMap);

        if (sendmsg) {
          messagetextController.text = '';

          messageId = "";
        }
      });
    }
  }

  Widget chatMessageTile(String message,bool sendByMe){
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomRight:
                      sendByMe ? Radius.circular(0) : Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomLeft:
                      sendByMe ? Radius.circular(24) : Radius.circular(0),
                ),
                color: sendByMe ? Colors.blue : Colors.red,
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }

  Widget chatMessages(){
    return StreamBuilder(
      stream: messageStream,
      builder: (context,snapshot){
        return snapshot.hasData? ListView.builder(
          padding: EdgeInsets.only(bottom:70,top:16),
          itemCount: snapshot.data.docs.length,
          reverse: true,
          itemBuilder: (context,index){
            DocumentSnapshot ds = snapshot.data.docs[index];
            return chatMessageTile(ds["message"],myUserName==ds["sendBy"]);
          }) : Center(child: CircularProgressIndicator());
      },
    );
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatroomId);
    setState(() {
      
    });
  }

  doThisOnLaunch() async {
    print("Herreee");
    await getMyInfoFromSharedPreference();
    getAndSetMessages();
  }

  @override
  void initState() {
    // TODO: implement initState
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey.withOpacity(0.8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messagetextController,
                        onChanged: (value) {
                          addMessage(false);
                        },
                        decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black)),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          addMessage(true);
                        },
                        child: Icon(Icons.send))
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
