# Bamboo_Scripts
Scripts used in Continuous Integration migration project during Summer 2015 Internship at CDK Global.
Automated the Windows Engineering team's BE, PT, and WE Builds in the Bamboo Platform.

The scripts were utilized in the following execution:
1. Precheck
  - Clone from remote repository
  - Set up environment for testing
2. Create RPS File Structure
  - Copy the files to a remote drive on the server
3. Table check
  - Ensure that all files in the structure are verified by comparing it to a given .TBL file
4. Email Request
 -Parse through the RPStemplate.txt form and fill in the required fields
 - Build Status with attached .txt file is sent to other teams in the company.
