
## 💡 Lab Link: [Administering an AlloyDB Database - GSP1086](https://www.cloudskillsboost.google/focuses/100851?parent=catalog)

## 🚀 Lab Solution [Watch Here](https://youtu.be/SI-VeAqKN6M)

---

## 💡 [Open this link in new tab](https://console.cloud.google.com/alloydb/clusters?referrer=search&project=)

1. Export the **ZONE** Name correctly
```
export ZONE=
```

2. Connect **SSH** of **`alloydb-client`**
```
gcloud compute ssh alloydb-client --zone=$ZONE --project=$DEVSHELL_PROJECT_ID --quiet
```

3. **Replacing ALLOYDB_ADDRESS with the Private IP address of the AlloyDB instance**
```
export ALLOYDB=
```

4. Below commands **store the Private IP address of the AlloyDB instance on the AlloyDB client VM**
```
echo $ALLOYDB  > alloydbip.txt 
```

5. This commands launch the **PostgreSQL (psql) client**
```
psql -h $ALLOYDB -U postgres
```

> You will be prompted to provide the postgres user's password **(`Change3Me`)** which you entered when you created the cluster

6. Input and run the following **SQL commands separately to enable the extension**
```
\c postgres
```
```
CREATE EXTENSION IF NOT EXISTS PGAUDIT;
```
```
select extname, extversion from pg_extension where extname = 'pgaudit';
```

7. Type **`\q`** to exit the psql client.

8. Type **`exit`** to close the terminal window.

---

### 💡 Click (+) icon to active 2nd Cloud Shell

1. Export the **REGION** Name correctly in **both Cloud Shell**
```
export REGION=
```

2. Run the below commands in your **first Cloud Shell**
```
gcloud alloydb instances create lab-instance-rp1 --project=$DEVSHELL_PROJECT_ID --region=$REGION --cluster=lab-cluster --instance-type=READ_POOL --cpu-count=2 --read-pool-node-count=2
```

3. Run the below commands in your **second Cloud Shell**
```
gcloud beta alloydb backups create lab-backup --region=$REGION --project=$DEVSHELL_PROJECT_ID --cluster=lab-cluster
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
