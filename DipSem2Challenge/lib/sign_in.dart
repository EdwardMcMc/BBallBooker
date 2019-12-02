import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

String name;
String email;
String imageUrl;

Future<String> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  // Checking if email and name is null
  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  name = user.displayName;
  email = user.email;
  imageUrl = user.photoUrl;

  final databaseReference = FirebaseDatabase.instance.reference();
  var uuid = new Uuid();
  Map<dynamic, dynamic> map;
  databaseReference.child('users/').once().then((DataSnapshot snapshot){
    bool userexists=false;
    if(snapshot.value!=null)
    {
      map=snapshot.value;
      for(int i=0;i<map.length;i++)
      {
        print(map.values.toList()[i]['email']);
        if (map.values.toList()[i]['email']==email)
        {
          userexists=true;
        }
      }
      if(!userexists)
      {
        String newid=uuid.v4();
        databaseReference.child("users/"+newid).set(
          { 'id':newid,
            'email':email,
            'name':name,
            'imageurl':imageUrl,
            'approved':'pending'
          }).then((onValue){});
        }
      }
      else{
        String newid=uuid.v4();
        databaseReference.child("users/"+newid).set(
          { 'id':newid,
            'email':email,
            'name':name,
            'imageurl':imageUrl,
            'approved':'pending' 
          }).then((onValue){});
      }
    });
  

  // Only taking the first part of the name, i.e., First Name
  if (name.contains(" ")) {
    name = name.substring(0, name.indexOf(" "));
  }

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async {
  await googleSignIn.signOut();

  print("User Sign Out");
}