
### 💡 Lab Link: [Simplify Network Connectivity for AlloyDB for PostgreSQL: Challenge Lab | GCC040 | ](https://www.cloudskillsboost.google/focuses/37981/?parent=game)

### 🚀 Lab Solution [Watch Here](https://youtu.be/Z9ekqroxjPE)

---

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---

### 🚨Copy and run the below commands in Cloud Shell:

```
curl -LO raw.githubusercontent.com/Techcps/Google-Cloud-Skills-Boost/master/Simplify%20Network%20Connectivity%20for%20AlloyDB%20for%20PostgreSQL%3A%20Challenge%20Lab/techcps040.sh
sudo chmod +x techcps040.sh
./techcps040.sh
```

---

```
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    medical_record_number VARCHAR(100) UNIQUE,
    last_visit_date DATE,
    primary_physician VARCHAR(100)
);


INSERT INTO patients (patient_id, first_name, last_name, date_of_birth, medical_record_number, last_visit_date, primary_physician)
VALUES 
(1, 'John', 'Doe', '1985-07-12', 'MRN123456', '2024-02-20', 'Dr. Smith'),
(2, 'Jane', 'Smith', '1990-11-05', 'MRN654321', '2024-02-25', 'Dr. Johnson');


CREATE TABLE clinical_trials (
    trial_id INT PRIMARY KEY,
    trial_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    lead_researcher VARCHAR(100),
    number_of_participants INT,
    trial_status VARCHAR(20)
);


INSERT INTO clinical_trials (trial_id, trial_name, start_date, end_date, lead_researcher, number_of_participants, trial_status)
VALUES 
    (1, 'Trial A', '2025-01-01', '2025-12-31', 'Dr. John Doe', 200, 'Ongoing'),
    (2, 'Trial B', '2025-02-01', '2025-11-30', 'Dr. Jane Smith', 150, 'Completed');

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
