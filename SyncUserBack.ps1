<#
    .SYNOPSIS
     Sync Cloud Users to On-Prem Local Domain
	
    .NOTES
     Script is provided as an example, it has no error handeling and is not production ready. App name and permissions is hard coded.
	 We Will Keep enhancing it and will inform you once it's ready to use in production environment
	 
	.ABOUTUS
	 Author  : Azure-Heroes (Mohammad Al Rousan)
	 Date    : 20-12-2020
	 Version : 0.3
#>

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path "aadlogs.txt" -append
Set-ExecutionPolicy Unrestricted -Force
$ErrorActionPreference = "Continue"


###
### Variables
###
$global:conneted= $False
$ConnectedLocalAD = $False
$AllUsersFilePath = "Allusers.csv"
$CloudOnlyUsersFilePath = "Cloudusers.csv"
$LocalDomainName = "azure-heroes.local"

function Get-Modules
{
	If (!(Get-Module -listavailable | where {$_.name -like "*AzureAD*"})) 
	{
		write-host "Installing Missing Model" -ForegroundColor Green
		Install-Module AzureAD -ErrorAction SilentlyContinue 
	} 
Else 
	{ 
		Import-Module AzureAD -ErrorAction SilentlyContinue		
	} 
	
If (!(Get-Module -listavailable | where {$_.name -like "*ActiveDirectory*"})) 
	{ 
	    write-host "Installing Missing Model" -ForegroundColor Green
		Install-Module ActiveDirectory -ErrorAction SilentlyContinue
	} 
Else 
	{ 
		Import-Module ActiveDirectory -ErrorAction SilentlyContinue		
	} 
}

function Connect-ToAD
{

Get-Modules

$azureConnection = Connect-AzureAD
if($azureConnection.Account -eq $null){
	
    $azureConnection  = Connect-AzureAD
	write-host "Failed To Connect..." -ForegroundColor Red
} else {
write-host "Connected Successfully!" -ForegroundColor Green
$global:conneted= $True	
}


}
function Get-AllUsers
{
	
	if($global:conneted) {
		Get-AzureADUser -all 1 | where {$_.UserType -eq "Member"} | select ObjectType,DisplayName,GivenName,Mail,Mobile,Surname, UserPrincipalName,AccountEnabled,ProxyAddresses,LastDirSyncTime,DirSyncEnabled | Out-GridView
	}  else {
		write-host "Please Connect To Azure AD First!"		
	}
}

function Export-AllUsers
{
	if($global:conneted) {
		Get-AzureADUser -all 1 | where {$_.UserType -eq "Member"} | select ObjectType,DisplayName,GivenName,Mail,Mobile,Surname, UserPrincipalName,AccountEnabled,@{Name='ProxyAddresses';Expression={[string]::join(";", ($_.ProxyAddresses))}},LastDirSyncTime,DirSyncEnabled | Export-Csv -Path $AllUsersFilePath
	} else {
		write-host "Please Connect To Azure AD First!"	 -ForegroundColor Red	
	}
}

function Get-CloudUsers
{
	if($conneted) {
		Get-AzureADUser -all 1 | where {$_.UserType -eq "Member" -and $_.DirSyncEnabled -eq $NULL} | select ObjectType,DisplayName,GivenName,Mail,Mobile,Surname, UserPrincipalName,AccountEnabled,ProxyAddresses,LastDirSyncTime,DirSyncEnabled | Out-GridView
	} else {
		write-host "Please Connect To Azure AD First!"  -ForegroundColor Red
	}
}


function Export-CloudUsers 
{
	if($global:conneted) {
		Get-AzureADUser -all 1 | where {$_.UserType -eq "Member" -and $_.DirSyncEnabled -eq $NULL} | select ObjectType,DisplayName,GivenName,Mail,Mobile,Surname, UserPrincipalName,AccountEnabled,@{Name='ProxyAddresses';Expression={[string]::join(";", ($_.ProxyAddresses))}},LastDirSyncTime,DirSyncEnabled | Export-Csv -Path $CloudOnlyUsersFilePath -NoTypeinformation
	}  else {
		write-host "Please Connect To Azure AD First!"  -ForegroundColor Red	
	}
}

function Connect-toLocalAD
{
$LocalDomainName = Read-Host "Please Enter your Local Domain e.g (azure-heroes.local)"

if([string]::IsNullOrEmpty($LocalDomainName))
	{	
		
		write-host "Wrong Input!" -ForegroundColor Red	
	} else {
		
		if (Test-Connection $LocalDomainName -Count 1 -ErrorAction SilentlyContinue) { write-host "Connected!" $ConnectedLocalAD= $True} else {write-host "Failed To Connect!" -ForegroundColor Red	 }
	}

}

function Create-AdUsers
{
if($ConnectedLocalAD)
{
	
$Users = Import-Csv -Path $CloudOnlyUsersFilePath
foreach ($User in $Users)            
{            
$Displayname = $User.'DisplayName'            
$UserFirstname = $User.'GivenName'            
$UserLastname = $User.'Surname'
$name = $User.'DisplayName'	        
$SAM = $User.'UserPrincipalName'            
$UPN = $User.'UserPrincipalName'
$ProxyAddresses= $User.'ProxyAddresses'.replace(";",",")
$Password = "P@ssw0rd@123"
$mail = $User.'Mail'
$Enabled=$User.'AccountEnabled'

New-ADUser -Name $name -DisplayName $Displayname -SamAccountName $SAM -UserPrincipalName $UPN -GivenName $UserFirstname -Surname $UserLastname -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $Enabled -ChangePasswordAtLogon $false -PasswordNeverExpires $false
write-host "Users Has been Synced Successfully" -ForegroundColor Green	
}
}
}

function Show-Menu
{
     param (
           [string]$Title = 'Syncing  Azure AD'
     )
     cls

	 Write-Host "=======================================================================" -ForegroundColor Yellow -BackgroundColor Blue
	 Write-Host "==                                                                   ==" -ForegroundColor Yellow -BackgroundColor Blue
     Write-Host "========================== $Title ==========================" -ForegroundColor Yellow -BackgroundColor Blue
	 Write-Host "=======================================================================" -ForegroundColor Yellow -BackgroundColor Blue
     Write-Host "==                                                                   ==" -ForegroundColor Yellow -BackgroundColor Blue
	 Write-Host "=======================================================================" -ForegroundColor Yellow -BackgroundColor Blue
	 Write-Host "C: Press 'C' Connect To Azure AD"
     Write-Host "1: Press '1' Get All Users"
	 Write-Host "2: Press '2' Export All Users to CSV"
     Write-Host "3: Press '3' Get Only Cloud User - Not Synced"
	 Write-Host "4: Press '4' Export Only Cloud User - Not Synced"
     Write-Host "5: Press '5' Connect To Local Domain"
	 Write-Host "6: Press '6' Sync the Exported Users -In CSV File- to Local Domain"
	

     Write-Host "Q: Press 'Q' to quit."
}


do
{
     Show-Menu
     $input = Read-Host "Please make a selection:"
     switch ($input)
     {
           'C' {
                cls
                'Option C: Connect To Azure AD:'
				
				 Connect-ToAD 
           } '1' {
                cls
                '#1: Get All Users:'
				
					Get-AllUsers

           } '2' {
                cls
                '#2: Export All Users to CSV:'
				Export-AllUsers
           } '3' {
                cls
                '#3: Get Only Cloud User - Not Synced:'
				Get-CloudUsers
           } '4' {
                cls
                '#4: Export Only Cloud User - Not Synced:'
				Export-CloudUsers
           } '5' {
                cls
                '#5: Connect To Local Domain:'
				Connect-toLocalAD
           } '6' {
                cls
                '#6: Sync the Exported Users -In CSV File- to Local Domain:'
				Create-AdUsers
           } 

	    'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')
