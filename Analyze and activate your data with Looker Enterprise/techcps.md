

### 💡 Lab Link: [Analyze and activate your data with Looker Enterprise](https://www.cloudskillsboost.google/focuses/88314?parent=catalog)

### 🚀 Lab Solution [Watch Here](https://youtu.be/Mw7IYav0iao)

---

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---

### 🚨 First, click the toggle button to turn on the Development mode.

![Techcps](https://github.com/Techcps/GSP-Short-Trick/assets/104138529/ef540cc4-e6ce-4e81-bf76-75c9ab00a42b)

---

### 🚨 Go to Develop > fintech > fintech.model file
```
# Place in `fintech` model
explore: +loan_details {
    query: techcps_2 {
      measures: [loan.outstanding_loans_amount]
    }
}

# Place in `fintech` model
explore: +loan_details {
    query: techcps_3 {
      dimensions: [loan.loan_status]
      measures: [loan.outstanding_loans_amount]
    }
}

# Place in `fintech` model
explore: +loan_details {
    query: techcps_4 {
      dimensions: [loan.state]
      measures: [loan.outstanding_count]
    }
}

# Place in `fintech` model
explore: +loan_details {
    query: techcps_5 {
      dimensions: [
        customer.address_state,
        customer.annual_income,
        customer.customer_id,
        customer.home_ownership,
        loan.interest_rate,
        loan.loan_status
      ]
    }
}
```
---

### Task 2 🚀

- **Visualization Type:** `Single Value`
- **Visualization bar, click Edit:** Formatting
- **Click:** Enable Conditional Formatting
- **Rules:** greater than `3000000000`
- **Style BG** `Red`
- **Create Dashboard:** `Loan Insights`
- **Title Name:** `Total Amount of Outstanding Loans`

---

### Task 3 🚀

- **Visualization Type:** `pie`
- **Title Name:** `Percentage of Outstanding Loans`

---

### Task 4 🚀

- **Visualization Type:** `bar`
- **Row Limit:** `10`
- **Title Name:** `Total Count of Outstanding Loans`

---

### Task 5 🚀

- **Visualization Type:** `table`
- **Row Limit:** 10.
- **Annual Income type:** `Descending order` ⬇️
- **Title Name:** `Top 10 Customers by Highest Income`

---

### Task 6 🚀

- **Total Amount of Outstanding Loans** `should refresh hourly`
- **Percentage of Outstanding Loans** `should refresh daily`
- **Top 10 Customers by Highest Income** `should refresh daily`



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
