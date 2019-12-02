
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PendingMembers extends StatefulWidget{
  PendingMembers(this.email);
  String email;

  @override
  State<StatefulWidget> createState() {
    return new PendingMembersState(email);
  }
}

class PendingMembersState extends State<PendingMembers>{
  
  PendingMembersState(this.email);
  String email;

  bool loading=true;
  final databaseReference = FirebaseDatabase.instance.reference();
  Map<dynamic, dynamic> membersMap;
  List<Card> memberslist;
   Map<dynamic, dynamic> user;

  

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    showmembers(){     
      databaseReference.child('/users/').once().then((DataSnapshot snapshot){
      membersMap=snapshot.value;
      memberslist=membersMap.values.toList().where((e)=>{e['approved']=='pending'}.first).map((item)=>
      Card(
        child:Row(
          children:<Widget>[
            Column(children: <Widget>[
              Image.network(item['imageurl']),
              Text(item['name']),],),         
            Column(children: <Widget>[
              Text(item['email']),
              Row(children: <Widget>[
                RaisedButton(
                color:Colors.green,
                child: Text("Approve"),
                onPressed: (){
                  databaseReference.child('/users/'+item['id']).set(
                    {
                      'id':item['id'],
                      'email':item['email'],
                      'name':item['name'],
                      'imageurl':item['imageurl'],
                      'approved':'approved'
                    }
                  );
                },
                ),
                RaisedButton(
                  color: Colors.red,
                child: Text("Reject"),
                onPressed: (){
                  databaseReference.child('/users/'+item['id']).set(
                    {
                      'id':item['id'],
                      'email':item['email'],
                      'name':item['name'],
                      'imageurl':item['imageurl'],
                      'approved':'Rejected'
                    }
                  );
                },
                )
              ],),
              
      ],),
            
      ]),)).toList();
      setState(() {
        loading=false;
      });
    });

          
    if(loading){
      return CircularProgressIndicator();
    }
    else if(user==null)
    {
      return Text("user=null");
    }
    else if (user['approved']!='approved')
    {
      return Text("Please Wait to be approved by an admin");
    }
    else{
         return Column(children: memberslist,); 
    }
    }

    return
    Column(children: <Widget>[ 
      Text('Pending Members'),
      showmembers()
    ],);
    
    
  }
}