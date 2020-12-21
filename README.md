# SyncAzureADBack
# Powershell Script used to sync the users from Azure Domain to Local Domain

## Well, as we all aware Microsft Azure AD Connect used to sync the users from Local Domain (ADDS) to Azure AD, so it's one-Way Sync
### I have wrote this script which allow the IT Admins to sync the users or retrive the users which they have cloud identity only


# The script has a menu as below:-

  1.	"C: Press 'C' Connect To Azure AD"
  2.	"1: Press '1' Get All Users"
  3.	"2: Press '2' Export All Azure AD Users to CSV"
  4.	"3: Press '3' Get Only Cloud identity Users - Not Synced"
  5.	"4: Press '4' Export Only Cloud identity Users - Not Synced"
  6.	"5: Press '5' Connect To Local Domain"
  7.	"6: Press '6' Sync the Exported Users -In CSV File- to Local Domain"


#### Note: You can Edit the CSV File before you sync it to your on Local Domain - in case you want to delete admin or services accounts
