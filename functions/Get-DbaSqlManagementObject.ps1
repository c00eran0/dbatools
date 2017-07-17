﻿function Get-DbaSqlManagementObject {
	<#
		.SYNOPSIS
			Gets SQL Mangaement Object versions installed on the machine.

		.DESCRIPTION
			The Get-DbaSqlManagementObject returns an object with the Version and the 
			Add-Type Load Template for each version on the server.

		.PARAMETER ComputerName
			The name of the target you would like to check
	
		.PARAMETER Credential
			This command uses Windows credentials. This parameter allows you to connect remotely as a different user.
	
		.PARAMETER VersionNumber
			This is the specific version number you are looking for. The function will look 
			for that version only.
		
		.PARAMETER Silent
			Use this switch to disable any kind of verbose messages
		
		.NOTES
			Tags: SMO
			Original Author: Ben Miller (@DBAduck - http://dbaduck.com)

			Website: https://dbatools.io
			Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
			License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

		.LINK
			https://dbatools.io/Get-DbaSqlManagementObject

		.EXAMPLE
			Get-DbaSqlManagementObject
	
			Returns all versions of SMO on the computer
		
		.EXAMPLE
			Get-DbaSqlManagementObject -VersionNumber 13
	
			Returns just the version specified. If the version does not exist then it will return nothing.
		
	#>
	#>
	[CmdletBinding()]
	param (
		[parameter(ValueFromPipeline)]
		[Alias("ServerInstance", "SqlServer", "SqlInstance")]
		[DbaInstanceParameter[]]$ComputerName = $env:COMPUTERNAME,
		[PSCredential][System.Management.Automation.CredentialAttribute()]
		$Credential,
		[int]$VersionNumber,
		[switch]$Silent
	)
	
	begin {
		$scriptblock = {
			$VersionNumber = [int]$args[0]
			
			Write-Verbose "Checking currently loaded SMO version"
			$loadedversion = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.Fullname -like "Microsoft.SqlServer.SMO,*" }
			
			if ($loadedversion) {
				$loadedversion = (($loadedversion.FullName -Split ", ")[1]).TrimStart("Version=")
			}
			
			Write-Verbose "Looking for SMO in the Global Assembly Cache"
			
			$smolist = (Get-ChildItem -Path "$env:SystemRoot\assembly\GAC_MSIL\Microsoft.SqlServer.Smo" | Sort-Object Name -Descending).Name
			
			foreach ($version in $smolist) {
				$array = $version.Split("__")
				if ($VersionNumber -eq 0) {
					Write-Verbose "Did not pass a version, looking for all versions"
					$currentversion = $array[0]
					[PSCustomObject]@{
						ComputerName = $env:COMPUTERNAME
						Version = $currentversion
						Loaded = $currentversion -eq $loadedversion
						LoadTemplate = "Add-Type -AssemblyName `"Microsoft.SqlServer.Smo, Version=$($array[0]), Culture=neutral, PublicKeyToken=89845dcd8080cc91`""
					}
				}
				else {
					Write-Verbose "Passed version $VersionNumber, looking for that specific version"
					if ($array[0].StartsWith("$VersionNumber.")) {
						Write-Verbose "Found the Version $VersionNumber"
						$currentversion = $array[0]
						[PSCustomObject]@{
							ComputerName = $env:COMPUTERNAME
							Version = $currentversion
							Loaded = $currentversion -eq $loadedversion
							LoadTemplate = "Add-Type -AssemblyName `"Microsoft.SqlServer.Smo, Version=$($array[0]), Culture=neutral, PublicKeyToken=89845dcd8080cc91`""
						}
					}
				}
			}
		}
	}
	
	process {
		foreach ($computer in $ComputerName.ComputerName) {
			try {
				Invoke-Command2 -ComputerName $computer -ScriptBlock $scriptblock -Credential $Credential -ArgumentList $VersionNumber -ErrorAction Stop
			}
			catch {
				Stop-Function -Continue -Message "Faiure" -ErrorRecord $_ -Target $ComputerName
			}
		}
	}
}