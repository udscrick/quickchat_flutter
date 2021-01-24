import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quickchat/helpers/sharedpref_helper.dart';

class DatabaseMethods{

  Future addUserToDB(String userId,Map<String,dynamic> userInfoMap)async {
    return await FirebaseFirestore.instance.collection("users").doc(userId).set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username)async {
    return FirebaseFirestore.instance.collection("users").where("username",isEqualTo: username)
    .snapshots();
  }

  Future addMessage(String chatroomid,String messageid,Map messageInfoMap)async{
    return FirebaseFirestore.instance.collection("chatrooms")
    .doc(chatroomid)
    .collection("chats")
    .doc(messageid)
    .set(messageInfoMap);
  }

  updateLastMessageSent(String chatroomid,Map lastMessageInfoMap){
    return FirebaseFirestore.instance
    .collection("chatrooms")
    .doc(chatroomid)
    .update(lastMessageInfoMap);
  }

  createChatRoom(String chatRoomId,Map chartroomInfoMap)
async{
  final snapshot = await FirebaseFirestore.instance
  .collection("chatrooms")
  .doc(chatRoomId)
  .get();

  if(snapshot.exists){
    //chat room already exists
    return true;
  }
  else{
    //Create chat room
    return FirebaseFirestore.instance.collection("chatrooms")
    .doc(chatRoomId)
    .set(chartroomInfoMap);
  }
}
Future<Stream<QuerySnapshot>>getChatRoomMessages(chatRoomId)async{
  return FirebaseFirestore.instance
  .collection("chatrooms")
  .doc(chatRoomId)
  .collection("chats")
  .orderBy("ts",descending:true)
  .snapshots();
}

Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myUsername = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }

    Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }

}