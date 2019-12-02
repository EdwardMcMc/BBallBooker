import 'package:dipsem2challenge/game_detail.dart';
import 'package:dipsem2challenge/sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'future.dart';

class Past extends StatefulWidget{
  Past(this.email);
  String email;

  @override
  State<StatefulWidget> createState() {
    return new PastState(email);
  }
}

class PastState extends State<Past>{
  final databaseReference = FirebaseDatabase.instance.reference();
   Map<dynamic, dynamic> map;
   bool loading=true;
  DateFormat dateFormat = DateFormat("MMMM d y");
  DateFormat timeFormat=DateFormat("h:mm a");
  String email;
  PastState(this.email);
  Map<dynamic, dynamic> user;
  @override
  void initState() {   
       databaseReference.child("users").once().then((DataSnapshot snapshot){
         Map<dynamic,dynamic> userMap=snapshot.value;
         for(int i=0;i<userMap.length;i++){
           if(userMap.values.toList()[i]['email']==email){
             setState(() {
          user=userMap.values.toList()[i];
         });
           }
         }        
       });
    databaseReference.child("games/").once().then((DataSnapshot snapshot){
    setState(() {
      map=snapshot.value;
      loading=false;
    });  
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Past Page'),
      showGames()
    ],);
  }
  
    showGames(){
       
    if(loading){
      return Center(child: CircularProgressIndicator());
    }
    else if(user==null){
      return Text("user=null");
    }
    else if(user['approved']!='approved'){
        return Text("Please Wait to be approved by an admin");
      }   
    else if(map!=null&&map.values!=null){
      databaseReference.child("/games/").once().then((DataSnapshot snapshot) {
      map = snapshot.value;
      });    
     return Column(children: map.values.toList().where((e)=>{DateTime.parse(e['date']).isBefore(DateTime.now())}.first).map((item)=>
        Card(child: 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: (){Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (context) => GameDetail(item['id'])),
                        );},
        child:Icon(Icons.attach_money)),
              Column(children: <Widget>[
          Text("Date: "+dateFormat.format(DateTime.parse(item['date']))),
          Text("Time: "+timeFormat.format(DateTime.parse(item['date']))),
          Text("Venue: "+item['venue'].toString())
        ],),
        GestureDetector(
                onTap: (){databaseReference.child('games/'+item['id']).remove().then((value){
                  });
                },
        child:Icon(Icons.delete))
        ],) ,)
     ).toList());
    }
    else{
      return Text("There Aren't Any Past Games");
    }
    
  }
  
  }