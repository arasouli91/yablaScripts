# REPORT LOW SUBTLEX COUNT OF YABLA VOCAB

### PROCESS WHITELIST
$whitelist = New-Object System.Collections.Generic.Dictionary"[String,Int]"
$whitelistFile = Get-Content -Path .\whitelist.txt
For ($i = 0; $i -lt $whitelistFile.Length; $i++) {
    $word = $whitelistFile[$i];
    $whitelist.TryAdd($word, 0); # dummy int val
}

### PROCESS SUBTLEX
# <word, subtlex count>
$subtlexDict = New-Object System.Collections.Generic.Dictionary"[String,Int]"

# get subtlex text
$file = Get-Content -Path .\subtlex.txt

# first add words from subtlex to dictionary
For ($i = 0; $i -lt $file.Length; $i++) {
    # split tokens
    $tokens = $file[$i].Split();
    # add <word, subtlex_count>
    $subtlexDict.Add($tokens[0], $tokens[1]);
}

### PROCESS YABLA VOCAB
# input yabla vocab text
$file = Get-Content -Path .\yablaVocab.txt

# <word, subtlex count>
$yablaList = New-Object 'Collections.Generic.List[Tuple[int,string, string]]'

# iterate yabla text
For ($i = 0; $i -lt $file.Length; $i += 2) {
    # split tokens
    $tokens = $file[$i].Split();
    $yablaWord = $tokens[0];
    $line = $file[$i];
    # ignore white listed words
    if ($whitelist.ContainsKey($yablaWord)) {
        continue;
    }
    # if yabla word is in dict and count < 500 or > 8000, add to result
    if ($subtlexDict.ContainsKey($yablaWord)) {
        $subtlexCount = $subtlexDict[$yablaWord];
        if ($subtlexCount -lt 500 || $subtlexCount -gt 8000) {
            $tuple = [tuple]::Create($subtlexCount, $yablaWord, $line);
            $yablaList.Add($tuple);
        }
    }
    # if yabla word is not in dict, report that as zero count
    else {
        $tuple = [tuple]::Create(0, $yablaWord, $line);
        $yablaList.Add($tuple);
    }
}

# sort list
$yablaList.Sort();

### MAKE DECISION ON EACH WORD
$yablaList
| ForEach-Object -Begin $null -Process {
    $outStr = $_.Item1.ToString() + " " + $_.Item3;
    Write-Output $outStr;
    $choice = Read-Host -Prompt "(1) Whitelist  (2) DeleteList";

    # OUTPUT TO WHITELIST AND DELETELIST
    if ($choice.Equals("1")) {
        Out-File -FilePath .\whitelist.txt -InputObject $_.Item2 -Append;
    }
    else {
        Out-File -FilePath .\deletelist.txt -InputObject $_.Item2 -Append;
    }
}
-End $null


# RESTARTING LATER DOESN'T MATTER
# BECAUSE MOST OF THEM ARE BEING SAVED ANYWAYS
# i.e. don't have to finish in one sitting
