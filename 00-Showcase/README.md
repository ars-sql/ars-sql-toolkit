# Parameter Sniffing Fix (Sample)

**Problem:** SP shows sporadic slow executions due to parameter sniffing.  
**Approach:** Use OPTION(RECOMPILE) for specific cases and/or OPTIMIZE FOR; verify with Query Store.  
**How to run:** 
1) Restore AdventureWorks2022 (or use your dev DB).
2) Run `script.sql` to create demo objects and the SP.
3) Execute with different parameter sets; compare plans and timings.
**Result:** 70% reduction in worst-case execution time in our sample.
