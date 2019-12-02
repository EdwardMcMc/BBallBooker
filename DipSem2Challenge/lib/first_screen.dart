

import 'package:dipsem2challenge/new_game.dart';
import 'package:dipsem2challenge/pending_members.dart';
import 'package:dipsem2challenge/sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


import 'login_page.dart';
import 'members.dart';
import 'past.dart';
import 'future.dart';

class FirstScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return _FirstScreenState();
  }
}


class _FirstScreenState extends State<FirstScreen> {
  int _currentIndex = 0;
  DateTime gameDate;
  final databaseReference = FirebaseDatabase.instance.reference();
  Map<dynamic, dynamic> user;
  bool loading=true;

   void initState() {   
       databaseReference.child("users").once().then((DataSnapshot snapshot){
         Map<dynamic,dynamic> userMap=snapshot.value;
         for(int i=0;i<userMap.length;i++){
           if(userMap.values.toList()[i]['email']==email){
             setState(() {
          user=userMap.values.toList()[i];
          loading=false;
         });
           }
         }

         setState(() {
        loading=false; 
       });

       });
    super.initState();
  }
  
  @override

    bool isapproved(){
      if(user!=null)
        {
        if(user['approved']=='approved')
          {
            return true;
          }
        else
          {
          print(user['approved']);
          return false;
          }
      }
      else
        {
          return false;
        }
      }
    
  
      showfirstpage(){

databaseReference.child("users").once().then((DataSnapshot snapshot){
         Map<dynamic,dynamic> userMap=snapshot.value;
         for(int i=0;i<userMap.length;i++){
           if(userMap.values.toList()[i]['email']==email){
             setState(() {
          user=userMap.values.toList()[i];
          loading=false;
         });
           }
         }        
       });

      if(loading)
      {
      return Scaffold(body:Center(child:CircularProgressIndicator())); 
      }
      else
      {
      return Scaffold(
      body:SingleChildScrollView( child:
      Column(
        children:[
        Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue[100], Colors.blue[400]],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(
                  imageUrl,
                ),
                radius: 60,
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 10),
              Text(
                'NAME',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                name,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'EMAIL',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
              Text(
                email,
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              RaisedButton(
                onPressed: () {
                  signOutGoogle();
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return LoginPage();}), ModalRoute.withName('/'));
                },
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 25, color: Colors.white),
                  ),
                ),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
              SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
      [Past(email),Future(email),Members(email),PendingMembers(email)][_currentIndex]
      
      ])),
      floatingActionButton: Visibility(
        visible: isapproved(),
        child:FloatingActionButton(          
          child: Icon(Icons.plus_one),
          tooltip: "Translate legislation",
          onPressed: () {
            Navigator.push(context,MaterialPageRoute<void>(builder: (context) => NewGame()),);    
          },
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        )),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.arrow_back),
                  title: Text('Past')
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.arrow_forward),
                  title: Text('Future')
                  ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.supervised_user_circle),
                  title:Text('Members')
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.supervisor_account),
                  title: Text("Pending Members")
                )
              ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        ),
    );
    }
    }

  Widget build(BuildContext context) {
    



    return showfirstpage();
    
  }




    void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}