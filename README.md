# ABAP Recognition Windows Processes
ABAP sample program to recognition Windows processes

## Basic functions
This program creates a *.bat* file with *tasklist* Windows command and saves it on client.
Then, this program executes the *.bat* file that generates a second file with *tasklist* return.
Finally, the second file size indicates that process is running (or not).

## Known limitations
1. The file creation on Windows root drive is locked to non-administrators users in many Windows versions. Maybe (not tested) file creation can be done in ERP temporary files folder.
2. Both file creation and read presents pop-ups to confirm actions. This can be bypassed including security rules in ERP security options (not tested).
