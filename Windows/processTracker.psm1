<#	
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.170
	 Created on:   	12/7/2019 5:57 PM
	 Created by:   	Mark Buckaway
	 Organization: 	
	 Filename:     	processTracker.psm1
	-------------------------------------------------------------------------
	 Module Name: 
	===========================================================================
#>


#region Process Tracker
function Stop-ProcessTracker
{
	<#
		.SYNOPSIS
			Stops and removes all processes from the list.
	#>
	#Stop the timer
	$timerProcessTracker.Stop()
	
	#Remove all the processes
	while ($ProcessTrackerList.Count -gt 0)
	{
		$process = $ProcessTrackerList[0].Process
		$ProcessTrackerList.RemoveAt(0)
		if (-not $process.HasExited)
		{
			Stop-Process -InputObject $process
		}
	}
}

$timerProcessTracker_Tick = {
	Update-ProcessTracker
}

function Update-ProcessTracker
{
	<#
		.SYNOPSIS
			Checks the status of each job on the list.
	#>
	
	#Poll the jobs for status updates
	$timerProcessTracker.Stop() #Freeze the Timer
	
	for ($index = 0; $index -lt $ProcessTrackerList.Count; $index++)
	{
		$psObject = $ProcessTrackerList[$index]
		
		if ($null -ne $psObject)
		{
			if ($null -ne $psObject.Process)
			{
				if ($psObject.Process.HasExited)
				{
					#Call the Complete Script Block
					if ($null -ne $psObject.CompleteScript)
					{
						#$results = Receive-Job -Job $psObject.Job
						Invoke-Command -ScriptBlock $psObject.CompleteScript -ArgumentList $psObject.Process
					}
					
					$ProcessTrackerList.RemoveAt($index)
					$index-- #Step back so we don't skip a job
				}
				elseif ($null -ne $psObject.UpdateScript)
				{
					#Call the Update Script Block
					Invoke-Command -ScriptBlock $psObject.UpdateScript -ArgumentList $psObject.Process
				}
			}
		}
		else
		{
			$ProcessTrackerList.RemoveAt($index)
			$index-- #Step back so we don't skip a job
		}
	}
	
	if ($ProcessTrackerList.Count -gt 0)
	{
		$timerProcessTracker.Start() #Resume the timer
	}
}

$ProcessTrackerList = New-Object System.Collections.ArrayList
function Add-ProcessTracker
{
	<#
		.SYNOPSIS
			Add a new process to the ProcessTracker and starts the timer.
	
		.DESCRIPTION
			Add a new process to the ProcessTracker and starts the timer.
	
		.PARAMETER  FilePath
			The path to executable.
	
		.PARAMETER ArgumentList
			The arguments to pass to the process.
	
		.PARAMETER CompletedScript
			The script block that will be called when the process is complete.
			The process is passed as an argument. The process argument is null when the job fails.
	
		.PARAMETER UpdateScript
			The script block that will be called each time the timer ticks.
			The process is passed as an argument.
	
		.PARAMETER RedirectOutputScript
			The script block that handles output from the process.
			Use $_.Data to access the output text.
	
		.PARAMETER RedirectErrorScript
			The script block that handles error output from the process.
			Use $_.Data to access the output text.
	
		.PARAMETER NoNewWindow
			Start the new process in the current console window.
	
		.PARAMETER WindowStyle
			Specifies the state of the window that is used for the new process. 
			Valid values are Normal, Hidden, Minimized, and Maximized. 
			The default value is Normal.
	
		.PARAMETER WorkingDirectory
			Specifies the location of the executable file or document that runs in the process. 
			The default is the current directory.
	
		.PARAMETER RedirectInput
			Redirects the input of the process. If this switch is set, the function will return the process object.
			Use the process object's StandardInput property to access the input stream.
	
		.PARAMETER PassThru
			Returns the process that was started.
	
		.PARAMETER SyncObject
			The object used to marshal the process event handler calls that are issued.
			You must pass a control to sync otherwise it will produce an error when redirecting output.

		.EXAMPLE
			 Add-ProcessTracker -FilePath 'notepad.exe' `
			-SyncObject $form1 `
			-CompletedScript {
				Param([System.Diagnostics.Process]$Process)
				$button.Enable = $true
			}`
			-UpdateScript {
				Param([System.Diagnostics.Process]$Process)
				Function-Animate $button
			}`
			-RedirectOutputScript { 
			# Use $_.Data to access the output text
				$textBox1.AppendText($_.Data)
				$textBox1.AppendText("`r`n")
			}
		.EXAMPLE
			$process = Add-ProcessTracker -FilePath 'powershell.exe' `
			-RedirectInput `
			-SyncObject $buttonRunProcess `
			-RedirectOutputScript {
				# Use $_.Data to access the output text
				$richtextbox1.AppendText($_.Data)
				$richtextbox1.AppendText("`r`n")
			}
			
			#Write to the console
			$process.StandardInput.WriteLine("Get-Process")
	
		.OUTPUTS
			 System.Diagnostics.Process
	#>
	
	[OutputType([System.Diagnostics.Process])]
	Param (
		[ValidateNotNull()]
		[Parameter(Mandatory = $true)]
		[string]$FilePath,
		[string]$Arguments,
		[string]$WorkingDirectory,
		[Parameter(Mandatory = $true)]
		[ValidateNotNull()]
		[System.ComponentModel.ISynchronizeInvoke]$SyncObject,
		[ScriptBlock]$CompletedScript,
		[ScriptBlock]$UpdateScript,
		[ScriptBlock]$RedirectOutputScript,
		[ScriptBlock]$RedirectErrorScript,
		[System.Diagnostics.ProcessWindowStyle]$WindowStyle = 'Normal',
		[switch]$RedirectInput,
		[switch]$NoNewWindow,
		[switch]$PassThru
	)
	
	#Start the Process
	try
	{
		$process = New-Object System.Diagnostics.Process
		$process.StartInfo.FileName = $FilePath
		$process.StartInfo.WindowStyle = $WindowStyle
		
		if ($NoNewWindow)
		{
			$process.StartInfo.CreateNoWindow = $true
		}
		
		if ($WorkingDirectory)
		{
			$process.StartInfo.WorkingDirectory = $WorkingDirectory
		}
		
		#Handle Redirection
		if ($RedirectErrorScript)
		{
			$process.EnableRaisingEvents = $true
			$process.StartInfo.UseShellExecute = $false
			$process.StartInfo.RedirectStandardError = $true
			$process.StartInfo.CreateNoWindow = $true
			$process.add_ErrorDataReceived($RedirectErrorScript)
		}
		
		if ($RedirectOutputScript)
		{
			$process.StartInfo.UseShellExecute = $false
			$process.StartInfo.RedirectStandardOutput = $true
			$process.add_OutputDataReceived($RedirectOutputScript)
		}
		
		if ($RedirectInput)
		{
			$process.EnableRaisingEvents = $true
			$process.StartInfo.UseShellExecute = $false
			$process.StartInfo.CreateNoWindow = $true
			$process.StartInfo.RedirectStandardInput = $true
			$PassThru = $true #Force the object to return
		}
		
		#Pass the arguments and sync with the form
		$process.StartInfo.Arguments = $Arguments
		$process.SynchronizingObject = $SyncObject
		$process.Start() | Out-Null
		
		#Begin the redirect reads
		if ($RedirectOutputScript)
		{
			$process.BeginOutputReadLine()
		}
		
		if ($RedirectErrorScript)
		{
			$process.BeginErrorReadLine()
		}
	}
	catch
	{
		Write-Error $_.Exception.Message
		$process = $null
	}
	
	if ($null -ne $process)
	{
		#Create a Custom Object to keep track of the Job & Script Blocks
		$members = @{
			"Process"	     = $process;
			"CompleteScript" = $CompletedScript;
			"UpdateScript"   = $UpdateScript
		}
		
		$psObject = New-Object System.Management.Automation.PSObject -Property $members
		
		[void]$ProcessTrackerList.Add($psObject)
		
		#Start the Timer
		if (-not $timerProcessTracker.Enabled)
		{
			$timerProcessTracker.Start()
		}
		
		#Return the process if using PassThru
		if ($PassThru)
		{
			return $process
		}
	}
	elseif ($null -ne $CompletedScript)
	{
		#Failed
		Invoke-Command -ScriptBlock $CompletedScript -ArgumentList $null
	}
	
}

Export-ModuleMember -Function *-ProcessTracker
Export-ModuleMember -Variable $ProcessTrackerList
#Export-ModuleMember -Variable $timerProcessTracker



