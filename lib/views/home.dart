import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quickchat/helpers/sharedpref_helper.dart';
import 'package:quickchat/services/database.dart';
import 'package:quickchat/views/chatscreen.dart';
import '../services/auth.dart';
import 'package:quickchat/views/signin.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  Stream userStream;
  Stream chatRoomsStream;
  TextEditingController searchUserNameTextController = TextEditingController();

    String chatroomId, messageId;
  String myName, myProfilePic, myEmail, myUserName;


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


   getMyInfoFromSharedPreference() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfileUrl();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myUserName = await SharedPreferenceHelper().getUserName();

  
  }


  onSearchClick()async {
    setState(() {
      isSearching = true;
      
    });
    userStream = await DatabaseMethods().getUserByUserName(searchUserNameTextController.text);
    setState(() {
      
    });
    
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName);
                })
            : Center(child: CircularProgressIndicator());
      },
    );
  }
  

  Widget searchUsersTile({String imgurl,name,email,username}){
return GestureDetector(
  onTap: (){
    var chatRoomId = getChatRoomIdByUsernames(username,myUserName);
    Map<String,dynamic> chatRoomInfoMap = {
      "users": [myUserName,username]
    };

    DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(name,username)));
  },
  child:   Row(children: [
  
    ClipRRect(
  
      borderRadius: BorderRadius.circular(40),
  
        child: Image.network(
  
        imgurl,
  
        width:40,
  
        height:40
  
      ),
  
    ),
  
    SizedBox(width:12),
  
    Column(
  
      crossAxisAlignment: CrossAxisAlignment.start,
  
      children: [
  
        Text(name),
  
        Text(email)
  
  
  
    ],)
  
  ],
  
  ),
);
  }

  Widget searchUserList(){
    return StreamBuilder(
      stream: userStream,
      builder: (context,snapshot){
        return snapshot.hasData? ListView.builder(
          itemCount: snapshot.data.docs.length,
          shrinkWrap: true,//Because list is inside the column widget
          itemBuilder: (context,index){
            DocumentSnapshot ds = snapshot.data.docs[index];
            return searchUsersTile(imgurl:ds["imgUrl"],name:ds["name"],email:ds["email"],username:ds["username"]);
          })
          :
          Center(child: CircularProgressIndicator(),);
    });
  }
 

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }
  
  onScreenLoaded() async {
    await getMyInfoFromSharedPreference();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuickChat'),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((e) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Icon(Icons.exit_to_app),
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            isSearching = false;
                            searchUserNameTextController.text = " ";
                          });
                        },
                        child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.arrow_back)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUserNameTextController,
                          onSubmitted: (value){
                               if(searchUserNameTextController.text!=''){
                                onSearchClick();
                              } 
                          } ,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "Search for usernames..."),
                        )),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearching = true;
                            });
                          },
                          child: GestureDetector(
                              onTap:(){
                              if(searchUserNameTextController.text!=''){
                                onSearchClick();
                              } 
                              
                              }, child: Icon(Icons.search)),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching?searchUserList():chatRoomsList()
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    print(
        "something bla bla ${querySnapshot.docs[0].id} ${querySnapshot.docs[0]["name"]}  ${querySnapshot.docs[0]["imgUrl"]}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(name, username)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                profilePicUrl,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 3),
                Text(widget.lastMessage)
              ],
            )
          ],
        ),
      ),
    );
  }
}