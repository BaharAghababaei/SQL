# SQL
sql projects

# 🌧️ Rainfall and Vessel Movement Analysis Dashboard

This project investigates the relationship between consecutive rainy days and vessel operations at grain port terminals, using real-world data from 2014 to 2018 from Vancouver port. The analysis integrates weather data with port activity records and evaluates how rain events influence vessel departures, cargo tonnage, and anchorage time.

---

## 📁 Project Contents

| File | Description |
|------|-------------|
| [`grain_analysis_report.pbix`](https://github.com/baharaghababaei/SQL/blob/main/docs/grain_analysis_report.pbix) | Interactive dashboard visualizing trends across rainfall thresholds and durations|
| [`port_analysis.sql`](https://github.com/baharaghababaei/SQL/blob/main/docs/port_analysis.sql) | MySQL code for rainfall sequence detection and port data analysis |

---

## 🧠 Analysis Summary

The SQL procedure calculates key performance metrics over rainy sequences where daily rainfall exceeds a defined threshold (default: **8mm**), including:
- 📦 **Average tonnage loaded per day**
- 🚢 **Average vessel departures per day**
- ⏱️ **Average anchorage hours per day**

These values are grouped by:
- Consecutive rainy days (1 to 6 days)
- Year
- Rainfall threshold (looped from 8mm to 70mm in SQL)

---

## 📊 Report Highlights (Power BI)

The Power BI file includes:
- A clean visual reports with separate graphs:
  - Vessel departures vs. rainy day duration
  - Tonnage loaded vs. rainy day duration
  - Anchorage hours vs. rainy day duration
- Interactive slicers for Year and Rainfall Threshold


---


## 📌 Notes

- Rainfall data was cleaned and missing values replaced with `0 mm`.
- All anchorage time values are in hours.
- Analysis uses only **outbound agri product shipments**.

---


