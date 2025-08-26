# Missing Indexes – Top N since SQL Server start

**What:** Finds top missing index recommendations with ready-to-edit CREATE INDEX statements.  
**Why:** Quick wins for read performance; start with high Estimated_Improvement.  
**How:** 
1) Connect to target DB.
2) Run the script.
3) Review suggested key/include columns; test in non-prod first.

**Notes:** DMV data resets on SQL Server restart; validate with workload tests.
