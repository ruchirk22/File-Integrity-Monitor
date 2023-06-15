

Write-Host ""
Write-host "What would you like to do?"
Write-Host "A) Collect new baseline?"
Write-Host "B) Begin monitoring files with saved Baseline?"
Write-Host ""

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

# Write-Host "User entered $($response)"

Function Calculate-File-Hash($filepath){
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}


Function Erase-Existing-Baseline(){
    $baselineExists = Test-Path -Path "F:\CyberSecurity\Projects\File Integrity Monitor using Hash\baseline.txt"

    if($baselineExists){
        #delete it
        Remove-Item -Path "F:\CyberSecurity\Projects\File Integrity Monitor using Hash\baseline.txt"
        }
}



if($response -eq "A".ToUpper()){
    #delete baseline if already exists
    Erase-Existing-Baseline
    
    #calculate hash from target files and store in baseline.txt
    #Write-Host "Calculate Hashes, make new baseline.txt" -ForegroundColor Green

    #Collect all files in target folder
    $files = Get-ChildItem -Path "F:\CyberSecurity\Projects\File Integrity Monitor using Hash\Text files"

    #for each file calculate hash and write to baseline.txt
    foreach($f in $files){
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "F:\CyberSecurity\Projects\File Integrity Monitor using Hash\baseline.txt" -Append
        }

}

elseif($response -eq "B".ToUpper()){
    #create an empty dictionary
    $fileHashDictionary = @{}

    #Load file hash from baseline.txt and store them in a dictionary
    $filePathsandHashes = Get-Content -Path "F:\CyberSecurity\Projects\File Integrity Monitor using Hash\baseline.txt"
    
    foreach($f in $filePathsandHashes){
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    #print the dictionary
    $fileHashDictionary

    Write-Host ""



    #Begin monitoring files continuously with saved baseline
        while($true){
            Start-Sleep -Seconds 1

            $files = Get-ChildItem -Path "F:\CyberSecurity\Projects\File Integrity Monitor using Hash\Text files"

            #for each file calculate hash and write to baseline.txt
            foreach($f in $files){
                $hash = Calculate-File-Hash $f.FullName
                #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath "F:\CyberSecurity\Projects\File Integrity Monitor using Hash\Text files\baseline.txt" -Append

                #Notify if a new file has been created
                if($fileHashDictionary[$hash.Path] -eq $null) {
                    # A new file has been created!
                    Write-Host "$($hash.Path) has been created!" -ForegroundColor Red
                }
                else{
                    #Notify if a file has been changed
                    if($fileHashDictionary[$hash.Path] -eq $hash.Hash){
                        #the file has not changed
                    }
                    else{
                        #the file has been compromised
                        Write-Host "$($hash.Path) has changed!!!" -ForegroundColor Magenta
                        }
                }


                foreach($key in $fileHashDictionary.Keys){
                    $baselinefilestillExists = Test-Path $key
                    if(-Not $baselinefilestillExists){
                        #one of the files must have been deleted
                        Write-Host "$($key) has been deleted!!" -ForegroundColor Yellow
                    }
                }

                
            }

        }

}