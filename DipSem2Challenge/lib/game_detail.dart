import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameDetail extends StatefulWidget{
  GameDetail(this.id);
  String id;
  @override
  State<StatefulWidget> createState() {
    return new GameDetailState(id);
  }
}

class GameDetailState extends State<GameDetail>{
  GameDetailState(this.id);
  String id;

final databaseReference = FirebaseDatabase.instance.reference();
  Map<dynamic, dynamic> map;
  Map<dynamic, dynamic> membersMap;
  bool loading=true;
  bool formloading=true;
  DateFormat dateFormat = DateFormat("MMMM d y");
  DateFormat timeFormat=DateFormat("h:mm a");
  String gameDate="unset gameDate";
  String gameVenue="unset gameVenue";
  String gameID="unset gameID";
  String gameMember="N/A";
  String gameCost="N/A";
  TextEditingController gameCostController=TextEditingController();
  final formKey=GlobalKey<FormState>();
  List<DropdownMenuItem> memberslist;
  @override
  void initState() {
    databaseReference.child("games/"+id).once().then((DataSnapshot snapshot){
    setState(() {
      map=snapshot.value;
      gameDate=map['date'];
      gameVenue=map['venue'];
      gameID=map['id'];
      if(map['cost']!=null)
      {gameCost=map['cost'];}
      if(map['member']!=null)
      {gameMember=map['member'];}
      loading=false;
    });  
    });
    databaseReference.child('users').once().then((DataSnapshot snapshot){
      membersMap=snapshot.value;
      memberslist=membersMap.values.toList().map((item)=>DropdownMenuItem(child:Row(children:<Widget>[Text(item['name']),Image.network(item['imageurl']),Text(item['email'])]),value: item['email'],)).toList();
      setState(() {
        formloading=false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Game Detail"),),
      body: Column(children:<Widget>[
        showGameDetail(),
        showGameForm()
        ]
    ));
  }

showGameDetail(){
  if(loading){
    return Center(child:CircularProgressIndicator());
  }
  else{
  return Center(child:Column(
        children: <Widget>[
          Text("Date:",style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold),),
          Text(dateFormat.format(DateTime.parse(gameDate))),
          Text("Time:",style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold),),
          Text(timeFormat.format(DateTime.parse(gameDate))),
          Text("Venue:",style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold),),
          Text(gameVenue),
          Text("Member email:",style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold),),
          Text(gameMember),
          Text("Cost:",style: TextStyle(fontSize: 20,fontWeight:FontWeight.bold),),
          Text(gameCost)
        ],
      ));
  }
}

showGameForm(){
  if(formloading)
  {return CircularProgressIndicator();}
  else{
  return Form(key:formKey,
  child: Column(children: <Widget>[
    TextFormField(
      decoration: InputDecoration(labelText: "Cost (\$)",icon: Icon(Icons.attach_money),hintText: gameCost),
      keyboardType: TextInputType.phone,
      validator: (value){
        if(value.isEmpty)
        {return "please Enter a Cost";}
        if(double.tryParse(value)==null)
        {return "please enter a numeric cost";}
        setState(() {
          gameCost=value;
        });
      },
    ),
    DropdownFormField(
      validator:(value){
        if(value==null)
        {
          return "Please Select Member";
        }
        setState(() {
          gameMember=value;
        });
      },
      onSaved:(value){
        setState(() {
          gameMember=value;
        });
      },
      decoration:InputDecoration(
        icon: Icon(Icons.verified_user),
        labelText: 'Member',  
      ),
      initialValue: null,
      items:memberslist
    ),
    RaisedButton(
      child: Text("Submit"),
      onPressed: ()
      {
        if(formKey.currentState.validate())
        {
          databaseReference.child("games/"+id).set(
            {
              'id':gameID,
              'date':gameDate,
              'venue':gameVenue,
              'cost':gameCost,
              'member':gameMember
            }
          );
          Navigator.pop(context);
        }
        
      },
    )
  ],),);}
}

}


class DropdownFormField<T> extends FormField<T> {
  DropdownFormField({
    Key key,
    InputDecoration decoration,
    T initialValue,
    List<DropdownMenuItem<T>> items,
    bool autovalidate = false,
    FormFieldSetter<T> onSaved,
    FormFieldValidator<T> validator,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          autovalidate: autovalidate,
          initialValue: items.contains(initialValue) ? initialValue : null,
          builder: (FormFieldState<T> field) {
            final InputDecoration effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            return InputDecorator(
              decoration:
                  effectiveDecoration.copyWith(errorText: field.hasError ? field.errorText : null),
              isEmpty: field.value == '' || field.value == null,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: field.value,
                  isDense: true,
                  onChanged: field.didChange,
                  items: items.toList(),
                ),
              ),
            );
          },
        );
}