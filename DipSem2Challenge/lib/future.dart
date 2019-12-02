import 'package:dipsem2challenge/game_detail.dart';
import 'package:dipsem2challenge/sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Future extends StatefulWidget{
  Future(this.email);
  String email;

  @override
  State<StatefulWidget> createState() {
    return new FutureState(email);
  }
}

class FutureState extends State<Future>{
  final databaseReference = FirebaseDatabase.instance.reference();
   Map<dynamic, dynamic> map;
   bool loading=true;
  DateFormat dateFormat = DateFormat("MMMM d y");
  DateFormat timeFormat=DateFormat("h:mm a");
  String email;
  FutureState(this.email);
  Map<dynamic, dynamic> user;
  var useless;
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
    try{
 setState(() {
      map=snapshot.value;
      loading=false;
    }); 
    }
    catch(e){}
    
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text('Future Page'),
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
      try{
        setState(() {
        map = snapshot.value;
        loading=false;
      });
      }
      catch(e){};
      

      
      });    
     return Column(children: map.values.toList().where((e)=>{DateTime.parse(e['date']).isAfter(DateTime.now())}.first).map((item)=>
       
        Card(child: 
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Icon(Icons.backspace,color: Colors.white,),
          Column(children: <Widget>[
            Text("Date: "+dateFormat.format(DateTime.parse(item['date']))),
            Text("Time: "+timeFormat.format(DateTime.parse(item['date']))),
            Text("Venue: "+item['venue'].toString())
          ],),
          //Padding(padding:EdgeInsets.fromLTRB(100,0,0,0),),
          GestureDetector(
                onTap: (){databaseReference.child('games/'+item['id']).remove().then((value){
                  });
                },
        child:Icon(Icons.delete))
        ],)
        
        
        ),
     ).toList());
    }
    else{
      return Text("There Aren't Any Future Games");
    }
    
  }
  
  }