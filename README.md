# SQL
sql projects

# 🌧️ Rainfall and Vessel Movement Analysis Dashboard

This project investigates the relationship between consecutive rainy days and vessel operations at port terminals, using real-world data from 2014 to 2018 from Vancouver port. The analysis integrates weather data with port activity records and evaluates how rain events influence vessel departures, cargo tonnage, and anchorage time.

---

## 📁 Project Contents

| File | Description |
|------|-------------|
| [`rainfall_vessels_threshold_analysis.xlsx`](https://github.com/baharaghababaei/SQL/blob/main/docs/rainfall_vessels_threshold_analysis.xlsx) | Excel dashboard with charts and summary stats |
| [`port_analysis.sql`](https://github.com/baharaghababaei/SQL/blob/main/docs/port_analysis.sql) | MySQL code for rainfall sequence detection and port data analysis |

---

## 🧠 Analysis Summary

The SQL procedure calculates key performance metrics over rainy sequences where daily rainfall exceeds a defined threshold (default: **8mm**), including:
- 📦 **Avg. tonnage loaded per day**
- 🚢 **Avg. number of vessels departing per day**
- ⏱️ **Avg. hours spent in anchorage**

These values are grouped by:
- Consecutive rainy days (1 to 6 days)
- Year
- Rainfall threshold (looped from 8mm to 70mm in SQL)

---

## 📊 Dashboard Highlights

The Excel file includes:
- A clean visual dashboard with line charts for:
  - Avg. vessels per day
  - Avg. tonnage per day
  - Avg. anchorage hours
- Summary statistics across all rainy sequences
- Insight callouts and formatted panels

---


## 📌 Notes

- Rainfall data was cleaned and missing values replaced with `0 mm`.
- All anchorage time values are in hours.
- Analysis uses only **outbound agri product shipments**.

---


