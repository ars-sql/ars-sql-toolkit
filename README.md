# ARS SQL Toolkit

Production-safe SQL Server scripts and patterns for **Development**, **Performance Tuning**, **DBA Operations**, **Monitoring**, **ETL/SSIS**, and **Reporting**.
All examples use anonymized objects and are safe to review.

## Quick Start (for reviewers)
Start at **/00-Showcase** for 8–12 guided examples:
- Parameter sniffing fix
- Indexing strategy (seek vs scan, included columns)
- Stats update vs RECOMPILE (when/why)
- Query Store regression analysis & fix
- Extended Events for slow queries
- Safe backup/maintenance templates
- Wait stats + perf counters baseline
- Clean export to Excel/SSRS/Power BI

## Structure
- **01-Development** – SPs, UDFs, Views, design patterns
	**T-SQL**
	**StoredProcedure **
	**Function**
	**View**
	**Trigger**
- **02-Performance-Tuning** – plans, Query Store, XE, indexing, stats, waits
	**Indexing**
	**Statistics**
	**QueryStore**
	**ExtendedEvent**
	**WaitAalysis**
	**DataTypeSizeCheck	**
- **03-DBA-Operations** – backups, maintenance, DBCC, jobs, DR
	**BackUps**
	**Maintenance**
	**SQLJobs**
	**Alerts**
- **04-Monitoring-Diagnostics** – health checks, baselines, perf counters
	**HealthChecks**
	**PerformanceCounters**
	**Reports**
- **05-ETL-SSIS** – file loaders, staging patterns, notes
	**SSIS-Script**
	**SSIS-Notes**
- **06-Reporting** – SSRS/Power BI notes, DAX samples, Excel outputs
	**PowerBI**
- **07-Utilities** – helper scripts & templates
- **08-Maintenance-Script//

## How to Use
1. Replace placeholders: `<SERVER_NAME>`, `<DB_NAME>`, `<SCHEMA>`, `<TABLE>`.
2. Test in **AdventureWorks2022** or a non-production DB.
3. Follow each showcase README for step-by-step runs.

## 👨‍💻 Author
**Alok Ranjan (ARS)**  
- 20+ years in SQL Server Development & DBA  
- Expert in Performance Tuning, Administration, ETL, Reporting  
- 6000+ freelance hours with US clients (TopTal)  
- Google Cloud Certified Professional Data Engineer  
- Author: *SQL Server Interview Question and Answer 2024* (Amazon)
