


### 💡 Lab Link: [Optimizing Performance of LookML Queries - GSP985](https://www.cloudskillsboost.google/focuses/22355?parent=catalog)

### 🚀 Lab Solution [Watch Here](https://youtu.be/GiUzHEnayvQ)

---

### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

---

### 🚨 First, click the toggle button to turn on the Development mode.

![Techcps](https://github.com/Techcps/GSP-Short-Trick/assets/104138529/ef540cc4-e6ce-4e81-bf76-75c9ab00a42b)

### 🚨 Go to Develop > qwiklabs-ecommerce LookML project.

### 🚨 Create `incremental_pdt` file
> Remove the default code and paste the below code:
```
# If necessary, uncomment the line below to include explore_source.
# include: "training_ecommerce.model.lkml"

view: incremental_pdt {
  derived_table: {
    datagroup_trigger: daily_datagroup
    increment_key: "created_date"
    increment_offset: 3
    explore_source: order_items {
      column: order_id {}
      column: sale_price {}
      column: created_date {}
      column: created_week {}
      column: created_month {}
      column: state { field: users.state }
    }
  }
  dimension: order_id {
    description: ""
    primary_key:  yes
    type: number
  }
  dimension: sale_price {
    description: ""
    type: number
  }
  dimension: created_date {
    description: ""
    type: date
  }
  dimension: created_week {
    description: ""
    type: date_week
  }
  dimension: created_month {
    description: ""
    type: date_month
  }
  dimension: state {
    description: "do like & subscribe techcps"
  }
  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd_0
  }
  measure: total_revenue {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }
}
```
---

### 🚨 Open training_ecommerce file
> Remove the default code and paste the below code:
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

datagroup: daily_datagroup {
  sql_trigger: SELECT FORMAT_TIMESTAMP('%F',
    CURRENT_TIMESTAMP(), 'America/Los_Angeles') ;;
  max_cache_age: "24 hours"
}

label: "E-Commerce Training"

explore: order_items {
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
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

explore: incremental_pdt {}


explore: +order_items {
  label: "Order Items - Aggregate Sales"
  aggregate_table: aggregate_sales {
    query: {
      dimensions: [order_items.created_date, users.state]
      measures: [order_items.average_sale_price,
        order_items.total_revenue]
    }
    materialization: {
      datagroup_trigger: daily_datagroup
      increment_key: "created_date"
      increment_offset: 3
    }
  }
}

explore: aggregated_orders {
  from: order_items
  label: "Aggregated Sales"
  join: users {
    type: left_outer
    sql_on: ${aggregated_orders.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
  aggregate_table: aggregate_sales {
    query: {
      dimensions: [aggregated_orders.created_date,
        users.state]
      measures: [aggregated_orders.average_sale_price,
        aggregated_orders.total_revenue]
    }
    materialization: {
      datagroup_trigger: daily_datagroup
      increment_key: "created_date"
      increment_offset: 3
    }
  }
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

