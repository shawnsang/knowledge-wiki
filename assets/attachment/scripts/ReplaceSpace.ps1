
# Get-ExecutionPolicy
# Set-ExecutionPolicy RemoteSigned
# Set-ExecutionPolicy Unrestricted -Scope Process


# if not set $rootPath, will use current folder as rootPath
if ($rootPath -eq $null ) {
	$rootPath = $PWD
}

Write-Host root Path is $rootPath

# Get-ChildItem $rootPath | ForEach-Object -Process{
# if($_ -is [System.IO.FileInfo])
#	{
#		Write-Host("file",$_.name);
#	}
# if($_ -is [System.IO.DirectoryInfo])
#	{
#		Write-Host("folder",$_.name);
#	}
#}


# get files in $rootPath
$files = Get-ChildItem $rootPath -Recurse * | Where {!$_.PSIsContainer}

foreach($file in $files) {


	if ($file.Name -match ' ' ) {
			Write-Host "Renameing file:" $file.FullName
			$newName = $file.Name -replace " ","_"
			$newPath = Join-Path -Path $file.DirectoryName -ChildPath $newName
			# Rename-Item -Path $file.FullName -NewName $newPath  
			Rename-Item -Path $file.FullName -NewName $newName
	
	}
	
 }
 
$folders = Get-ChildItem $rootPath -Recurse * | Where {$_.PSIsContainer}

[Array]::Reverse($folders)
foreach($folder in $folders) {
	if ($folder.Name -match ' '){
			Write-Host "Renameing folder: " $folder.FullName
			$newfolderName = $folder.Name -replace " ","_"
			Rename-Item -Path $folder.FullName -NewName $newfolderName  
	}


#	$file.name | Out-File -Width 5000 -FilePath $grepKekka1 -Append
#	$file.fullname | Out-File -Width 5000 -FilePath $grepKekka2 -Append
#	if (file.Name -match pattern ) {
#	newName = file.Name -replace ' ', '_'
#	newPath = Join-Path -Path file.DirectoryName -ChildPath newName
#	echo Rename-Item -Path file.FullName -NewName newPath | Out-File -FilePath "D:\output.txt" -Append
	
#	}
	
 }
 
Write-Host "complete rename"