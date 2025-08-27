Name: Applying_column_level_encryption_on_a_table.sql
    Description :
        - Demonstrates step-by-step process to apply column-level encryption in SQL Server.
        - Creates Service Master Key, Database Master Key, Self-signed Certificate, and Symmetric Key.
        - Adds encrypted columns and migrates existing data into encrypted format.
        - Provides queries to read/decrypt data and filter encrypted columns.
        - Implements INSTEAD OF trigger to handle insert/update seamlessly with encryption.
    Execution Instruction:
        - Before execution: Run in a test environment; update database and key/certificate details as needed.
        - After execution: Verify encryption/decryption logic; validate that insert/update operations work transparently.

