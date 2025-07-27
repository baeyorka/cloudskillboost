
### 💡 Lab Link: [Configure Replication and Enable Point-in-Time-Recovery for Cloud SQL for PostgreSQL | GSP922 | ](https://www.cloudskillsboost.google/focuses/22795?parent=catalog)

### 🚀 Lab Solution [Watch Here](https://www.youtube.com/@techcps)

---

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---

### 🚨Copy and run the below commands in Cloud Shell:

```
curl -LO raw.githubusercontent.com/Techcps/Google-Cloud-Skills-Boost/master/Configure%20Replication%20and%20Enable%20Point-in-Time-Recovery%20for%20Cloud%20SQL%20for%20PostgreSQL/techcps922.sh
sudo chmod +x techcps922.sh
./techcps922.sh
```

---

### 🚀Task 2. Enable and run point-in-time recovery

```
gcloud sql connect postgres-orders --user=postgres --quiet
```
- **When prompted, enter the password `supersecret!`**

```
\c orders
```
- **When prompted, enter the password `supersecret!` again.**

```
SELECT COUNT(*) FROM distribution_centers;
```
```
INSERT INTO distribution_centers VALUES(-80.1918,25.7617,'Miami FL',11);
SELECT COUNT(*) FROM distribution_centers;
```

```
\q
```

```
export UTCP=$(date --rfc-3339=seconds)

export CLOUD_SQL_INSTANCE=postgres-orders

export NEW_INSTANCE_NAME=postgres-orders-pitr
gcloud sql instances clone $CLOUD_SQL_INSTANCE $NEW_INSTANCE_NAME \
    --point-in-time="$UTCP"
```

### 🚀 It could take 10 minutes or more for the replica to be created and ready for use

```
gcloud sql operations list --instance=postgres-orders-pitr --project=$DEVSHELL_PROJECT_ID
```

---

### 🚀 Task 3. Confirm database has been restored to the correct point-in-time



```
gcloud sql connect postgres-orders-pitr --user=postgres --quiet
```
- **When prompted, enter the password `supersecret!`**

```
\c orders
```
- **When prompted, enter the password `supersecret!` again.**

```
SELECT COUNT(*) FROM distribution_centers;
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
