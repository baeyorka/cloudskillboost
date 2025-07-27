
### 💡 Lab Link: [Google Chat Bot - Apps Script | GSP250 | ](https://www.cloudskillsboost.google/focuses/32756?parent=catalog)

### 🚀 Lab Solution [Watch Here](https://youtu.be/7suytKhecWo)

---

### ⚠️ Disclaimer
- **This script and guide are provided for the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---

### 🚨Click on the `Code.gs` file and remove the defualt code
- **Add the below code**
  
```
function onMessage(event) {
  console.log('Message received from user: ', event.message.sender.name);
  var message = event.message.text;
  var response = CardService.newTextParagraph().setText("You said: " + message);
  
  return CardService.newCardBuilder()
    .setHeader(CardService.newCardHeader().setTitle("Response"))
    .addSection(CardService.newCardSection().addWidget(response))
    .build();
}

function onAddToSpace(event) {
  console.log('Attendance Bot added in ', event.space.name);
  if (event.space.type === 'ROOM') {
    return {text: `Thanks for adding me to the room, ${event.space.displayName}!`};
  } else {
    return {text: 'Thanks for adding me to this DM!'};
  }
}

function onRemoveFromSpace(event) {
  console.log('Attendance Bot removed from ', event.space.name);
}

function onCardClick(event) {
  // Handle card click actions here.
  console.log('Card button clicked: ', event.action.parameters);
} 
```

### 🚨Click on the `Appsscript.json` file and remove the defualt code
- **Add the below code**
```
{
  "timeZone": "Asia/Kolkata",
  "dependencies": {},
  "exceptionLogging": "STACKDRIVER",
  "chat": {},
  "runtimeVersion": "V8"
}
```

### 🚨Click on the `Code.gs` file and remove the defualt code
- **Add the below code**
  
```
var DEFAULT_IMAGE_URL = 'https://goo.gl/bMqzYS';
var HEADER = {
  header: {
    title : 'Attendance Bot',
    subtitle : 'Log your vacation time',
    imageUrl : DEFAULT_IMAGE_URL
  }
};

/**
 * Creates a card-formatted response.
 * @param {object} widgets the UI components to send
 * @return {object} JSON-formatted response
 */
function createCardResponse(widgets) {
  return {
    cards: [HEADER, {
      sections: [{
        widgets: widgets
      }]
    }]
  };
}

/**
 * Responds to a MESSAGE event triggered
 * in Google Chat.
 *
 * @param event the event object from Google Chat
 * @return JSON-formatted response
 */
function onMessage(event) {
  var userMessage = event.message.text;

  var widgets = [{
    "textParagraph": {
      "text": "You said: " + userMessage
    }
  }];

  console.log('You said:', userMessage);

  return createCardResponse(widgets);
}
  function onRemoveFromSpace(event) {
    console.log('Attendance Bot removed from ', event.space.name);
  }
  
  function onCardClick(event) {
    // Handle card click actions here.
    console.log('Card button clicked: ', event.action.parameters);
  } 
```

### 🚨Click on the `Code.gs` file and remove the defualt code
- **Add the below code**
  
```
var DEFAULT_IMAGE_URL = 'https://goo.gl/bMqzYS';
var HEADER = {
  header: {
    title : 'Attendance Bot',
    subtitle : 'Log your vacation time',
    imageUrl : DEFAULT_IMAGE_URL
  }
};
  
/**
  * Creates a card-formatted response.
  * @param {object} widgets the UI components to send
  * @return {object} JSON-formatted response
  */
function createCardResponse(widgets) {
  return {
    cards: [HEADER, {
      sections: [{
        widgets: widgets
      }]
    }]
  };
}
  
var REASON = {
  SICK: 'Out sick',
  OTHER: 'Out of office'
};
/**
  * Responds to a MESSAGE event triggered in Google Chat.
  * @param {object} event the event object from Google Chat
  * @return {object} JSON-formatted response
  */
function onMessage(event) {
  console.info(event);
  var reason = REASON.OTHER;
  var name = event.user.displayName;
  var userMessage = event.message.text;

  // If the user said that they were 'sick', adjust the image in the
  // header sent in response.
  if (userMessage.indexOf('sick') > -1) {
    // Hospital material icon
    HEADER.header.imageUrl = 'https://goo.gl/mnZ37b';
    reason = REASON.SICK;
  } else if (userMessage.indexOf('vacation') > -1) {
    // Spa material icon
    HEADER.header.imageUrl = 'https://goo.gl/EbgHuc';
  }
  
  var widgets = [{
    textParagraph: {
      text: 'Hello, ' + name + '.<br>Are you taking time off today?'
    }
  }, {
    buttons: [{
      textButton: {
        text: 'Set vacation in Gmail',
        onClick: {
          action: {
            actionMethodName: 'turnOnAutoResponder',
            parameters: [{
              key: 'reason',
              value: reason
            }]
          }
        }
      }
    }, {
      textButton: {
        text: 'Block out day in Calendar',
        onClick: {
          action: {
            actionMethodName: 'blockOutCalendar',
            parameters: [{
              key: 'reason',
              value: reason
            }]
          }
        }
      }
    }]
  }];
  return createCardResponse(widgets);
}
  function onRemoveFromSpace(event) {
    console.log('Attendance Bot removed from ', event.space.name);
  }
  
  function onCardClick(event) {
    // Handle card click actions here.
    console.log('Card button clicked: ', event.action.parameters);
  }  
  
/**
  * Responds to a CARD_CLICKED event triggered in Google Chat.
  * @param {object} event the event object from Google Chat
  * @return {object} JSON-formatted response
  * @see https://developers.google.com/chat/reference/message-formats/events
  */
function onCardClick(event) {
  console.info(event);
  var message = '';
  var reason = event.action.parameters[0].value;
  if (event.action.actionMethodName == 'turnOnAutoResponder') {
    turnOnAutoResponder(reason);
    message = 'Turned on vacation settings.';
  } else if (event.action.actionMethodName == 'blockOutCalendar') {
    blockOutCalendar(reason);
    message = 'Blocked out your calendar for the day.';
  } else {
    message = "I'm sorry; I'm not sure which button you clicked.";
  }
  return { text: message };
}
  
var ONE_DAY_MILLIS = 24 * 60 * 60 * 1000;
/**
  * Turns on the user's vacation response for today in Gmail.
  * @param {string} reason the reason for vacation, either REASON.SICK or REASON.OTHER
  */
function turnOnAutoResponder(reason) {
  var currentTime = (new Date()).getTime();
  Gmail.Users.Settings.updateVacation({
    enableAutoReply: true,
    responseSubject: reason,
    responseBodyHtml: "I'm out of the office today; will be back on the next business day.<br><br><i>Created by Attendance Bot!</i>",
    restrictToContacts: true,
    restrictToDomain: true,
    startTime: currentTime,
    endTime: currentTime + ONE_DAY_MILLIS
  }, 'me');
}

/**
  * Places an all-day meeting on the user's Calendar.
  * @param {string} reason the reason for vacation, either REASON.SICK or REASON.OTHER
  */
function blockOutCalendar(reason) {
  CalendarApp.createAllDayEvent(reason, new Date(), new Date(Date.now() + ONE_DAY_MILLIS));
}

```

---

### Congratulations, you're all done with the lab 😄

---

### 🌐 Join our Community

- <img src="https://github.com/user-attachments/assets/a4a4b767-151c-461d-bca1-da6d4c0cd68a" alt="icon" width="25" height="25"> **Join our [Telegram Channel](https://t.me/Techcps) for the latest updates & [Discussion Group](https://t.me/Techcpschat) for the lab enquiry**
- <img src="https://github.com/user-attachments/assets/aa10b8b2-5424-40bc-8911-7969f29f6dae" alt="icon" width="25" height="25"> **Join our [WhatsApp Community](https://whatsapp.com/channel/0029Va9nne147XeIFkXYv71A) for the latest updates**
- <img src="https://github.com/user-attachments/assets/b9da471b-2f46-4d39-bea9-acdb3b3a23b0" alt="icon" width="25" height="25"> **Follow us on [LinkedIn](https://www.linkedin.com/company/techcps/) for updates and opportunities.**
- <img src="https://github.com/user-attachments/assets/a045f610-775d-432a-b171-97a2d19718e2" alt="icon" width="25" height="25"> **Follow us on [TwitterX](https://twitter.com/Techcps_/) for the latest updates**
- <img src="https://github.com/user-attachments/assets/84e23456-7ed3-402a-a8a9-5d2fb5b44849" alt="icon" width="25" height="25"> **Follow us on [Instagram](https://instagram.com/techcps/) for the latest updates**
- <img src="https://github.com/user-attachments/assets/fc77ddc4-5b3b-42a9-a8da-e5561dce0c70" alt="icon" width="25" height="25"> **Follow us on [Facebook](https://facebook.com/techcps/) for the latest updates**

---

# <img src="https://github.com/user-attachments/assets/6ee41001-c795-467c-8d96-06b56c246b9c" alt="icon" width="45" height="45"> [Techcps](https://www.youtube.com/@techcps) Don't Forget to like share & subscribe

### Thanks for watching and stay connected :)
---
