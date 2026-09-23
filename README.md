# Sierra ILS Collection Development - High Ratio-Youth Automated Report
![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Python](https://img.shields.io/badge/python-%233670A0.svg?style=for-the-badge&logo=python&logoColor=ffdd54)

## Summary
**What it does:** This automated report highlights youth print titles with high demand (a minimum 2:1 hold-to-item ratio) and those with holds but zero holdable copies. The ratio calculation only includes actively holdable items.

**Impact:** Delivers a weekly automated report of in-demand titles to help the Collection Development team quickly respond to customer demand and easily assess and optimize inventory levels.

## Features and Deliverables

**Automated Email:**

<img width="488" height="589" alt="Youth High Ratio Holds Email" src="https://github.com/user-attachments/assets/ffab6f30-117c-415f-b58e-4bad5803dec1" />

**Attached Excel Report:**

<img width="1468" height="936" alt="High-Ratio-Youth" src="https://github.com/user-attachments/assets/4d9da211-6c90-4e22-8eae-ecf709549812" />

Beyond identifying youth print titles with a 2:1 hold-to-item ratio or holds on titles zero holdable copies, the report streamlines decision-making by including:

- Total frozen holds: Tracks outstanding demand that is currently paused.
- Pending orders: Shows how many orders have already been placed and are awaiting fulfillment.
- Publication year: Provides immediate context on the age and relevance of the material.
- Billed item data: Flags when an item has been billed, and includes circ data for the item.

<img width="1462" height="857" alt="High-Ratio-Youth" src="https://github.com/user-attachments/assets/5502914d-aca9-4684-b1e3-cd68d6b5d022" />

## Data Pipeline Architecture
This repository features an automated data pipeline that generates, formats, and distributes Excel reports via email. The system integrates Windows Task Scheduler, a Batch script, SQL, and Python to handle the end-to-end workflow without manual intervention. The automated process is fully productionized within a Windows environment.

**Workflow Overview:**

[Windows Task Scheduler] ──> [orchestrator.bat] ──> [main.py] ──> [Sub-modules & SQL] ──> [Report delivered to Email Inbox]

**Repository Contents & Security Note:**

To comply with data security policies, the core Python automation scripts have been omitted from this public repository. Instead, this repository provides:
- The SQL Data-Extraction Script: The exact logic used to pull and aggregate Sierra ILS production data.
- Manual Alternative: If you do not have an automated environment, you can run the provided SQL script manually in pgAdmin and export the results directly to a spreadsheet.

## Acknowledgments
The automated pipeline is built off the brilliant work of Gem Stone-Logan. For more information on implementing the automated system, please see her IUG presentations, [Automating Reports with Python.](https://www.gemstonelogan.com/presentations.html)
