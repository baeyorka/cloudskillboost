
### 💡 Lab Link: [Looker Functions and Operators - GSP857](https://www.cloudskillsboost.google/focuses/17873?parent=catalog)

### 🚀 Lab Solution [Watch Here](https://youtu.be/WWpU7-3zBoU)

---

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---
### 🚨 First, click the toggle button to turn on the Development mode.

![techcps](https://github.com/user-attachments/assets/6cca5cb5-9419-4a89-93c1-cfb7acddd61a)

---

```
# Place in `faa` model
explore: +flights {
  query: task_1{
      dimensions: [depart_week, distance_tiered]
      measures: [count]
      filters: [flights.depart_date: "2003"]
    }
  }


# Place in `faa` model
explore: +flights {
  query: task_2{
      dimensions: [aircraft_origin.state]
      measures: [percent_cancelled]
      filters: [flights.depart_date: "2000"]
    }
  }


# Place in `faa` model
explore: +flights {
    query: task_3{
      dimensions: [aircraft_origin.state]
      measures: [cancelled_count, count]
      filters: [flights.depart_date: "2004"]
    }
}


# Place in `faa` model
explore: +flights {
    query: task_4{
      dimensions: [carriers.name]
      measures: [total_distance]
    }
}


# Place in `faa` model
explore: +flights {
    query:task_5{
      dimensions: [depart_year, distance_tiered]
      measures: [count]
      filters: [flights.depart_date: "after 2000/01/01"]
    }
}

```
---

### Task 1:

- Under **Flights** > **Dimensions**, click on the **Pivot** data button for **Distance Tiered**.
- Change visualization type to **Line**
- Click Edit > **Plot** Select the **Legend Align** as **Left**
- **Run**, and select Save > **As a Look**
- Title Name **Flight Count by Departure Week and Distance Tier**

---

### Task 2
- **Run**, and select Save > **As a Look**
- Title Name **Percent of Flights Cancelled by State in 2000**

---

### Task 3
- In the Expression **field**, add the following **Table Calculation**:
```
${flights.cancelled_count}/${flights.count}
```
- Name: **Percent Cancelled**
- **Run**, and select Save > **As a Look**
- Title Name **Percent of Flights Cancelled by Aircraft Origin 2004**


---

### Task 4

- In the **Data** bar, click on the **Totals** checkbox next to Row Limit
- Next to **Custom Fields**, click + **Add**. Select **Table Calculation**.
```
${flights.total_distance}/${flights.total_distance:total}
```
- Change visualization type to **Bar**.
- **Run**, and select Save > **As a Look**
- Title Name **Percent of Total Distance Flown by Carrier**

---

### Task 5
- Next to **Custom Fields**, click **+ Add**. Select **Table Calculation**.
```
(${flights.count}-pivot_offset(${flights.count}, -1))/pivot_offset(${flights.count}, -1)
```

- Click **Flight Count** and select **Hide from Visualization**
- Change visualization type to **Table**.
- Edit > Formatting > Click Toggle the **Enable Conditional Formatting**
- **Depart Date** dimension group, click on the **Pivot data**
- **Run**, and select Save > **As a Look**
- Title Name **YoY Percent Change in Flights flown by Distance, 2000-Present**


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
