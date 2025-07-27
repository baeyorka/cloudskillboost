


### 💡 Lab Name: [Answering Complex Questions Using Native Derived Tables with LookML GSP935](https://www.cloudskillsboost.google/focuses/21214?parent=catalog)

### 🚀 Lab Solution [Watch Here](https://youtu.be/g6E0yg2WxEs)

---

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---
### 🚨 First, click the toggle button to turn on the Development mode.

![techcps](https://github.com/user-attachments/assets/6cca5cb5-9419-4a89-93c1-cfb7acddd61a)

---

### 🚨 Go to Develop > qwiklabs-ecommerce
- 🚀 Create view file **`brand_order_facts`**
> Replace the below commands on here!!
```
view: brand_order_facts {
  derived_table: {
    explore_source: order_items {
      column: product_brand { field: inventory_items.product_brand }
      column: total_revenue {}
      derived_column: brand_rank {
        sql: row_number() over (order by total_revenue desc) ;;
      }
      filters: [order_items.created_date: "365 days"]
      
      bind_filters: {
        from_field: order_items.created_date
        to_field: order_items.created_date
      }
    }
  }
  
  dimension: brand_rank {
    hidden: yes
    type: number
  }
  dimension: product_brand {
    description: ""
  }
  
  dimension: brand_rank_concat {
    label: "Brand Name"
    type: string
    sql: ${brand_rank} || ') ' || ${product_brand} ;;
  }
  
  dimension: brand_rank_top_5 {
    hidden: yes
    type: yesno
    sql: ${brand_rank} <= 5 ;;
  }
  
  dimension: brand_rank_grouped {
    label: "Brand Name Grouped"
    type: string
    sql: case when ${brand_rank_top_5} then ${brand_rank_concat} else '6) Other' end ;;
  }
  
  dimension: total_revenue {

    description: ""
    value_format: "$#,##0.00"
    type: number
  }
}

```

---

### 🚀 Open the training_ecommerce.model file
> Replace the below commands on here!!
```
connection: "bigquery_public_data_looker"

# include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"

datagroup: training_ecommerce_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: training_ecommerce_default_datagroup

label: "E-Commerce Training"

explore: order_items {
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: brand_order_facts {
    type: left_outer
    sql_on: ${inventory_items.product_brand} = ${brand_order_facts.product_brand} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: events {
  join: event_session_facts {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
    relationship: many_to_one
  }
  join: event_session_funnel {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
    relationship: many_to_one
  }
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

# Place in `training_ecommerce` model
explore: +order_items {
  query: techcps_1 {
    dimensions: [brand_order_facts.brand_rank_grouped]
    measures: [total_revenue]
  }
}

# Place in `training_ecommerce` model
explore: +order_items {
    query: techcps_2 {
      dimensions: [inventory_items.product_brand]
      measures: [total_revenue]
    }
}

# Place in `training_ecommerce` model
explore: +order_items {
    query: techcps_3 {
      dimensions: [brand_order_facts.brand_rank_grouped, created_date, users.age, users.country]
      measures: [total_revenue]
      filters: [
        order_items.created_date: "365 days",
        users.age: ">21",
        users.country: "USA"
      ]
    }
}


```
---

- Set **Ascending Order**: Brand Order Facts Brand Name Grouped
- Set the Row Limit to **10**
- Title your Look: **Ranked Brand Revenue**



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
