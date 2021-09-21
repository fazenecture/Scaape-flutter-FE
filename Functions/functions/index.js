const functions = require("firebase-functions");
const admin = require('firebase-admin');
const { Change } = require("firebase-functions");
admin.initializeApp(functions.config().firebase);

var movies, allUsers; 

// exports.weekly_job = functions.pubsub.topic('weekly-tick').onPublish((event) => {
//   getMoviesAndUsers();
// });  

// function getMoviesAndUsers () {
//   firebase.database().ref(moviesRef).on('value', function(snapshot) {
//     movies = snapshot.val();
//     firebase.database().ref(allUsersRef).on('value', function(snapshot) {
//         allUsers = snapshot.val();
//         createRecommendations();
//     });
// });
// }

exports.getuserprofile = functions.database.ref('/UserDetails/{chutiya}').onWrite(async (change) =>{
    const  snap = change.after; 
    const val = snap.val();
    const Activity = val.Activity;
    const uid = val.uid;

    const db = admin.database();
const refer = db.ref('Scaapes');

// Attach an asynchronous callback to read the data at our posts reference
refer.on('value', (snapshot) => {
    console.log('yha pe aa gye');
  console.log(snapshot.val());
  const myval = snapshot.val();
  myval.forEach(myval, function(i){
      console.log(myval[i].Status);
      if(myval[i].Activity == Activity){
        console.log("gb")
    }
  })
  
}, (errorObject) => {
  console.log('The read failed: ' + errorObject.name);
}); 
});

// function createRecommendations () {
//   // do something magical with movies and allUsers here.

//   // then write the recommendations to each user's profiles kind of like 
//   userRef.update({"userRecommendations" : {"reco1" : "Her", "reco2", "Black Mirror"}});
//   // etc. 
// }
