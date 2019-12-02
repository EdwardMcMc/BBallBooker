import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class NewGame extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return new NewGameState();
  }
}

class NewGameState extends State<NewGame>{
  DateTime _gameDate;
  String _gameVenue;
  String _dateLabelText="Select a Date";
  final _formKey = GlobalKey<FormState>();
  DateFormat dateFormat = DateFormat("MMMM d y");
  final databaseReference = FirebaseDatabase.instance.reference();
  var uuid = new Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Game"),),
      body: Center(child:Column(children: <Widget>[
        RaisedButton.icon(
          icon:Icon(Icons.calendar_today),
          onPressed: () {
            DatePicker.showDateTimePicker(
              context, 
              showTitleActions: true, 
              minTime: DateTime(2019,1,1),//.now(),
              maxTime: DateTime(2021, 1, 1),
              onChanged: (date) {
              print('change $date');
              },
              onConfirm: (date) {
                setState(() {
                  _gameDate=date;
                _dateLabelText=dateFormat.format(date);
                });
                print('confirm $date');
              },
              currentTime: DateTime.now(),
              locale: LocaleType.en
              );
            },
          label: Text(_dateLabelText),
          ),
          Form(key:_formKey,
          child:
          TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Venue',
                        icon: Icon(Icons.local_cafe)
                        ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a Venue';
                        }
                      else if(value.length>100) {
                        return 'Please enter no more than 10 characters';
                        }
                      _gameVenue=value;
                      return null;
                      },
                    onFieldSubmitted: (value) {
                      _gameVenue=value;
                      }, 
                    )),
                    RaisedButton(child: Text('Submit'),onPressed: (){
                      if(_formKey.currentState.validate()){
                        String newid=uuid.v4();
                      databaseReference.child("games/"+newid).set(
                        {
                          'id':newid,
                         'date':_gameDate.toIso8601String(),
                         'venue':_gameVenue 
                        }).then((onValue){
                          Navigator.pop(context,"posted");
                        });
                      }
                    },)
      ],),)
    );
  }
}