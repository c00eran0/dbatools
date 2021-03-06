function New-DbaAgentJobStep {
    <#
.SYNOPSIS 
New-DbaAgentJobStep creates a new job step for a job

.DESCRIPTION
New-DbaAgentJobStep creates a new job in the SQL Server Agent for a specific job

.PARAMETER SqlInstance
SQL Server instance. You must have sysadmin access and server version must be SQL Server version 2000 or greater.

.PARAMETER SqlCredential
Allows you to login to servers using SQL Logins as opposed to Windows Auth/Integrated/Trusted. To use:
$scred = Get-Credential, then pass $scred object to the -SqlCredential parameter. 
To connect as a different Windows user, run PowerShell as that user.

.PARAMETER Job
The name of the job to which to add the step.

.PARAMETER StepId
The sequence identification number for the job step. Step identification numbers start at 1 and increment without gaps.

.PARAMETER StepName
The name of the step.

.PARAMETER SubSystem
The subsystem used by the SQL Server Agent service to execute command.
Allowed values 'ActiveScripting','AnalysisCommand','AnalysisQuery','CmdExec','Distribution','LogReader','Merge','PowerShell','QueueReader','Snapshot','Ssis','TransactSql'
The default is 'TransactSql'

.PARAMETER Command
The commands to be executed by SQLServerAgent service through subsystem.

.PARAMETER CmdExecSuccessCode 
The value returned by a CmdExec subsystem command to indicate that command executed successfully.

.PARAMETER OnSuccessAction 
The action to perform if the step succeeds.
Allowed values  "QuitWithSuccess" (default), "QuitWithFailure", "GoToNextStep", "GoToStep".
The text value van either be lowercase, uppercase or something in between as long as the text is correct.

.PARAMETER OnSuccessStepId 
The ID of the step in this job to execute if the step succeeds and OnSuccessAction is "GoToStep".

.PARAMETER OnFailAction 
The action to perform if the step fails.
Allowed values  "QuitWithSuccess" (default), "QuitWithFailure", "GoToNextStep", "GoToStep".
The text value van either be lowercase, uppercase or something in between as long as the text is correct.

.PARAMETER OnFailStepId 
The ID of the step in this job to execute if the step fails and OnFailAction is "GoToNextStep".

.PARAMETER Database
The name of the database in which to execute a Transact-SQL step. The default is 'master'.

.PARAMETER DatabaseUser 
The name of the user account to use when executing a Transact-SQL step. 

.PARAMETER RetryAttempts
The number of retry attempts to use if this step fails. The default is 0.

.PARAMETER RetryInterval
The amount of time in minutes between retry attempts. The default is 0.

.PARAMETER OutputFileName
The name of the file in which the output of this step is saved.

.PARAMETER Flag
Sets the flag(s) for the job step.

Flag                                    Description
----------------------------------------------------------------------------
AppendAllCmdExecOutputToJobHistory      Job history, including command output, is appended to the job history file.
AppendToJobHistory                      Job history is appended to the job history file.
AppendToLogFile                         Job history is appended to the SQL Server log file.
AppendToTableLog                        Job history is appended to a log table.
LogToTableWithOverwrite                 Job history is written to a log table, overwriting previous contents.
None                                    Job history is not appended to a file.
ProvideStopProcessEvent                 Job processing is stopped.

.PARAMETER ProxyName
The name of the proxy that the job step runs as.

.PARAMETER WhatIf
Shows what would happen if the command were to run. No actions are actually performed.

.PARAMETER Confirm
Prompts you for confirmation before executing any changing operations within the command.

.PARAMETER Silent
Use this switch to disable any kind of verbose messages

.PARAMETER Force
The force parameter will ignore some errors in the parameters and assume defaults.

.NOTES 
Original Author: Sander Stad (@sqlstad, sqlstad.nl)
Tags: Agent, Job, Job Step
	
Website: https://dbatools.io
Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

.LINK
https://dbatools.io/New-DbaAgentJobStep

.EXAMPLE   
New-DbaAgentJobStep -SqlInstance sql1 -Job Job1 -StepName Step1
Create a step in "Job1" with the name Step1 with the default subsystem TransactSql.

.EXAMPLE   
New-DbaAgentJobStep -SqlInstance sql1 -Job Job1 -StepName Step1 -Database msdb
Create a step in "Job1" with the name Step1 where the database will the msdb

.EXAMPLE   
New-DbaAgentJobStep -SqlInstance sql1 -Job Job1 -StepName Step1 -Database msdb
Create a step in "Job1" with the name Step1 where the database will the msdb

.EXAMPLE   
New-DbaAgentJobStep -SqlInstance sql1, sql2, sql3 -Job Job1 -StepName Step1 -Database msdb
Create a step in "Job1" with the name Step1 where the database will the "msdb" for multiple servers

.EXAMPLE   
New-DbaAgentJobStep -SqlInstance sql1, sql2, sql3 -Job Job1, Job2, 'Job Three' -StepName Step1 -Database msdb
Create a step in "Job1" with the name Step1 where the database will the "msdb" for multiple servers for multiple jobs

.EXAMPLE   
sql1, sql2, sql3 | New-DbaAgentJobStep -Job Job1 -StepName Step1 -Database msdb
Create a step in "Job1" with the name Step1 where the database will the "msdb" for multiple servers using pipe line
#>
	
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
	param (
		[parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Alias("ServerInstance", "SqlServer")]
		[object[]]$SqlInstance,
		[Parameter(Mandatory = $false)]
		[System.Management.Automation.PSCredential]$SqlCredential,
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[object[]]$Job,
		[Parameter(Mandatory = $false)]
		[int]$StepId,
		[Parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$StepName,
		[Parameter(Mandatory = $false)]
		[ValidateSet('ActiveScripting', 'AnalysisCommand', 'AnalysisQuery', 'CmdExec', 'Distribution', 'LogReader', 'Merge', 'PowerShell', 'QueueReader', 'Snapshot', 'Ssis', 'TransactSql')]
		[string]$Subsystem = 'TransactSql',
		[Parameter(Mandatory = $false)]
		[string]$Command,
		[Parameter(Mandatory = $false)]
		[int]$CmdExecSuccessCode,
		[Parameter(Mandatory = $false)]
		[ValidateSet('QuitWithSuccess', 'QuitWithFailure', 'GoToNextStep', 'GoToStep')]
		[string]$OnSuccessAction = 'QuitWithSuccess',
		[Parameter(Mandatory = $false)]
		[int]$OnSuccessStepId = 0,
		[Parameter(Mandatory = $false)]
		[ValidateSet('QuitWithSuccess', 'QuitWithFailure', 'GoToNextStep', 'GoToStep')]
		[string]$OnFailAction = 'QuitWithFailure',
		[Parameter(Mandatory = $false)]
		[int]$OnFailStepId,
		[Parameter(Mandatory = $false)]
		[string]$Database,
		[Parameter(Mandatory = $false)]
		[string]$DatabaseUser,
		[Parameter(Mandatory = $false)]
		[int]$RetryAttempts,
		[Parameter(Mandatory = $false)]
		[int]$RetryInterval,
		[Parameter(Mandatory = $false)]
		[string]$OutputFileName,
		[Parameter(Mandatory = $false)]
		[ValidateSet('AppendAllCmdExecOutputToJobHistory', 'AppendToJobHistory', 'AppendToLogFile', 'LogToTableWithOverwrite', 'None', 'ProvideStopProcessEvent')]
		[string[]]$Flag,
		[Parameter(Mandatory = $false)]
		[string]$ProxyName,
		[switch]$Silent,
		[Parameter(Mandatory = $false)]
		[bool]$Force
	)
	
	begin {
		# Check the parameter on success step id
		if (($OnSuccessAction -ne 'GoToStep') -and ($OnSuccessStepId -ge 1)) {
			Stop-Function -Message "Parameter OnSuccessStepId can only be used with OnSuccessAction 'GoToStep'." -Target $SqlInstance
			return
		}
		
		# Check the parameter on success step id
		if (($OnFailAction -ne 'GoToStep') -and ($OnFailStepId -ge 1)) {
			Stop-Function -Message "Parameter OnFailStepId can only be used with OnFailAction 'GoToStep'." -Target $SqlInstance
			return
		}
	}
	
	process {
		
		if (Test-FunctionInterrupt) { return }
		
		foreach ($instance in $sqlinstance) {
			# Try connecting to the instance
			Write-Message -Message "Attempting to connect to $instance" -Level Output
			try {
				$Server = Connect-SqlServer -SqlServer $instance -SqlCredential $SqlCredential
			}
			catch {
				Stop-Function -Message "Could not connect to Sql Server instance" -Target $instance -Continue
			}
			
			foreach ($j in $Job) {
				
				# Check if the job exists
				if ($Server.JobServer.Jobs.Name -notcontains $j) {
					Write-Message -Message "Job $j doesn't exists on $instance" -Warning
				}
				else {
					# Create the job step object
					try {
						# Get the job
						$smojob = $Server.JobServer.Jobs[$j]
						
						# Create the job step
						$smojobStep = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobStep
						
						# Set the job where the job steps belongs to
						$smojobStep.Parent = $smojob
					}
					catch {
						Stop-Function -Message "Something went wrong creating the job step. `n$($_.Exception.Message)" -Target $instance -Continue
					}
					
					#region job step options
					# Setting the options for the job step
					if ($StepName) {
						# Check if the step already exists
						if ($Server.JobServer.Jobs[$j].JobSteps.Name -notcontains $StepName) {
							$smojobStep.Name = $StepName
						}
						elseif ($NewName -and $Force) {
							Write-Message -Message "Step $StepName already exists for job. Force is used. Setting job step name to $NewName" -Level Verbose
						}
						else {
							Stop-Function -Message "The step name $StepName already exists for job $j" -Target $instance -Continue
						}
					}
					
					if ($StepId) {
						# Check if the used step id is already in place
						if ($smojob.JobSteps.ID -notcontains $StepId) {
							Write-Message -Message "Setting job step step id to $StepId" -Level Verbose
							$smojobStep.ID = $StepId
						}
						else {
							Stop-Function -Message "The step id $StepId already exists for job $j" -Target $instance -Continue
						}
						
					}
					else {
						# Get the job step count
						$smojobStep.ID = $smojob.JobSteps.Count + 1
					}
					
					if ($Subsystem) {
						Write-Message -Message "Setting job step subsystem to $Subsystem" -Level Verbose
						$smojobStep.Subsystem = $Subsystem
					}
					
					if ($Command) {
						Write-Message -Message "Setting job step command to $Command" -Level Verbose
						$smojobStep.Command = $Command
					}
					
					if ($CmdExecSuccessCode) {
						Write-Message -Message "Setting job step command exec success code to $CmdExecSuccessCode" -Level Verbose
						$smojobStep.CommandExecutionSuccessCode = $CmdExecSuccessCode
					}
					
					if ($OnSuccessAction) {
						Write-Message -Message "Setting job step success action to $OnSuccessAction" -Level Verbose
						$smojobStep.OnSuccessAction = $OnSuccessAction
					}
					
					if ($OnSuccessStepId) {
						Write-Message -Message "Setting job step success step id to $OnSuccessStepId" -Level Verbose
						$smojobStep.OnSuccessStep = $OnSuccessStepId
					}
					
					if ($OnFailAction) {
						Write-Message -Message "Setting job step fail action to $OnFailAction" -Level Verbose
						$smojobStep.OnFailAction = $OnFailAction
					}
					
					if ($OnFailStepId) {
						Write-Message -Message "Setting job step fail step id to $OnFailStepId" -Level Verbose
						$smojobStep.OnFailStep = $OnFailStepId
					}
					
					if ($Database) {
						# Check if the database is present on the server
						if ($Server.Databases.Name -contains $Database) {
							Write-Message -Message "Setting job step database name to $Database" -Level Verbose
							$smojobStep.DatabaseName = $Database
						}
						else {
							Stop-Function -Message "The database is not present on instance $instance." -Target $instance -Continue
						}
					}
					
					if ($DatabaseUser -and $DatabaseName) {
						# Check if the username is present in the database
						if ($Server.Databases[$DatabaseName].Users.Name -contains $DatabaseUser) {
							
							Write-Message -Message "Setting job step database username to $DatabaseUser" -Level Verbose
							$smojobStep.DatabaseUserName = $DatabaseUser
						}
						else {
							Stop-Function -Message "The database user is not present in the database $DatabaseName on instance $instance." -Target $instance -Continue
						}
					}
					
					if ($RetryAttempts) {
						Write-Message -Message "Setting job step retry attempts to $RetryAttempts" -Level Verbose
						$smojobStep.RetryAttempts = $RetryAttempts
					}
					
					if ($RetryInterval) {
						Write-Message -Message "Setting job step retry interval to $RetryInterval" -Level Verbose
						$smojobStep.RetryInterval = $RetryInterval
					}
					
					if ($OutputFileName) {
						Write-Message -Message "Setting job step output file name to $OutputFileName" -Level Verbose
						$smojobStep.OutputFileName = $OutputFileName
					}
					
					if ($ProxyName) {
						# Check if the proxy exists
						if ($Server.JobServer.ProxyAccounts.Name -contains $ProxyName) {
							Write-Message -Message "Setting job step proxy name to $ProxyName" -Level Verbose
							$smojobStep.ProxyName = $ProxyName
						}
						else {
							Stop-Function -Message "The proxy name $ProxyName doesn't exist on instance $instance." -Target $instance -Continue
						}
					}
					
					if ($Flag.Count -ge 1) {
						Write-Message -Message "Setting job step flag(s) to $($Flags -join ',')" -Level Verbose
						$smojobStep.JobStepFlags = $Flag
					}
					#endregion job step options
					
					# Execute 
					if ($PSCmdlet.ShouldProcess($instance, "Creating the job step $StepName")) {
						try {
							Write-Message -Message "Creating the job step" -Level Output
							
							# Create the job step 
							$smojobStep.Create()
							$smojob.Alter()
						}
						catch {
							Stop-Function -Message "Something went wrong creating the job step. `n$($_.Exception.Message)" -Target $instance -Continue
						}
					}
					
					# Return the job step
					$smojobStep
				}
			} # foreach object job
		} # foreach object instance
	} # process
	
	end {
		Write-Message -Message "Finished creating job step(s)." -Level Output
	}
}
