

gcloud auth list

export PROJECT_ID=$(gcloud config get-value project)

export PROJECT_ID=$DEVSHELL_PROJECT_ID

gcloud services enable dialogflow.googleapis.com

gcloud services enable cloudfunctions.googleapis.com


export RUNTIME="nodejs10"
export TRIGGER="--trigger-http"


curl -LO https://raw.githubusercontent.com/Techcps/Google-Cloud-Skills-Boost/master/Adding%20a%20Phone%20Gateway%20to%20a%20Virtual%20Agent/pigeon-travel-gsp-793-cloud-function/index.js

curl -LO https://raw.githubusercontent.com/Techcps/Google-Cloud-Skills-Boost/master/Adding%20a%20Phone%20Gateway%20to%20a%20Virtual%20Agent/pigeon-travel-gsp-793-cloud-function/package.json


sleep 60

PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format='value(projectNumber)')

deploy_function() {
gcloud functions deploy dialogflowFirebaseFulfillment \
    --project=$DEVSHELL_PROJECT_ID \
    --region=$REGION \
    --runtime=$RUNTIME \
    --trigger-http \
    --source=. \
    --allow-unauthenticated \
    --quiet 
}

SERVICE_NAME="dialogflowFirebaseFulfillment"

while true; do
  deploy_function
  if gcloud functions describe $SERVICE_NAME --region $REGION &> /dev/null; then
    echo "Function deployed successfully."
    break
  else
    echo "Retrying, please subscribe to techcps[https://www.youtube.com/@techcps]"
    sleep 10
  fi
done



cat > index.js <<'EOF_CP'
// See https://github.com/dialogflow/dialogflow-fulfillment-nodejs
// for Dialogflow fulfillment library docs, samples, and to report issues
'use strict';
 
const functions = require('firebase-functions');
const {WebhookClient} = require('dialogflow-fulfillment');
const {Card, Suggestion} = require('dialogflow-fulfillment');
const admin = require('firebase-admin');

process.env.DEBUG = 'dialogflow:debug'; // enables lib debugging statements

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();
 
exports.dialogflowFirebaseFulfillment = functions.https.onRequest((request, response) => {
  const agent = new WebhookClient({ request, response });
  console.log('Dialogflow Request headers: ' + JSON.stringify(request.headers));
  console.log('Dialogflow Request body: ' + JSON.stringify(request.body));

function reservation(agent) {
   let id = agent.parameters.reservationnumber.toString();
	let collectionRef = db.collection('reservations');
	let userDoc = collectionRef.doc(id);
	return userDoc.get()
		.then(doc => {
			if (!doc.exists) {
				agent.add('placeholder');
				agent.setFollowupEvent('custom_fallback');
			} else {
				db.collection('reservations').doc(id).update({
					newname: agent.parameters.newname
				}).catch(error => {
					console.log('Transaction failure:', error);
					agent.add('placeholder');
					agent.setFollowupEvent('custom_fallback');
					return Promise.reject();
				});
				agent.add('Ok. I have updated the name on the reservation.');
			}
			return Promise.resolve();
		}).catch(() => {
			agent.add('placeholder');
			agent.setFollowupEvent('custom_fallback');
		});
}
  
  function welcome(agent) {
    agent.add(`Welcome to my agent!`);
  }
 
  function fallback(agent) {
    agent.add(`I didn't understand`);
    agent.add(`I'm sorry, can you try again?`);
  }

  // // Uncomment and edit to make your own intent handler
  // // uncomment `intentMap.set('your intent name here', yourFunctionHandler);`
  // // below to get this function to be run when a Dialogflow intent is matched
  // function yourFunctionHandler(agent) {
  //   agent.add(`This message is from Dialogflow's Cloud Functions for Firebase editor!`);
  //   agent.add(new Card({
  //       title: `Title: this is a card title`,
  //       imageUrl: 'https://developers.google.com/actions/images/badges/XPM_BADGING_GoogleAssistant_VER.png',
  //       text: `This is the body text of a card.  You can even use line\n  breaks and emoji! 💁`,
  //       buttonText: 'This is a button',
  //       buttonUrl: 'https://assistant.google.com/'
  //     })
  //   );
  //   agent.add(new Suggestion(`Quick Reply`));
  //   agent.add(new Suggestion(`Suggestion`));
  //   agent.setContext({ name: 'weather', lifespan: 2, parameters: { city: 'Rome' }});
  // }

  // // Uncomment and edit to make your own Google Assistant intent handler
  // // uncomment `intentMap.set('your intent name here', googleAssistantHandler);`
  // // below to get this function to be run when a Dialogflow intent is matched
  // function googleAssistantHandler(agent) {
  //   let conv = agent.conv(); // Get Actions on Google library conv instance
  //   conv.ask('Hello from the Actions on Google client library!') // Use Actions on Google library
  //   agent.add(conv); // Add Actions on Google library responses to your agent's response
  // }
  // // See https://github.com/dialogflow/fulfillment-actions-library-nodejs
  // // for a complete Dialogflow fulfillment library Actions on Google client library v2 integration sample

  // Run the proper function handler based on the matched Dialogflow intent name
  let intentMap = new Map();
  intentMap.set('Default Welcome Intent', welcome);
  intentMap.set('Default Fallback Intent', fallback);
  intentMap.set('name.reservation-getname', reservation);
  // intentMap.set('your intent name here', yourFunctionHandler);
  // intentMap.set('your intent name here', googleAssistantHandler);
  agent.handleRequest(intentMap);
});

EOF_CP

sleep 10

gcloud functions deploy dialogflowFirebaseFulfillment \
    --project=$DEVSHELL_PROJECT_ID \
    --region=$REGION \
    --runtime=$RUNTIME \
    --trigger-http \
    --source=. \
    --allow-unauthenticated \
    --quiet 

