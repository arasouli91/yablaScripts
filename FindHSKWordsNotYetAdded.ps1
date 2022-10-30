# REPORT HSK WORDS THAT HAVE NOT YET BEEN ADDED

# Get yabla vocab
# go through hsk words
# if hsk word doesn't exist, add to output

# we wont rely on prompt this time, instead manually edit..probably faster
# we should make 2 lists
# let's add these words now
# let's add these words later
# then the only words that get deleted just have way too much familiarity to add


### PROCESS YABLA VOCAB
# input yabla vocab text
$file = Get-Content -Path .\yablaVocab.txt

# <word, subtlex count>
$yablaList = New-Object 'System.Collections.Generic.HashSet[String]'
#$yablaList = New-Object 'Collections.Generic.List[Tuple[int,string, string]]'

# iterate yabla text
For ($i = 0; $i -lt $file.Length; $i += 2) {
    $yablaWord = $file[$i].Split()[0];
    $yablaList.Add($yablaWord); # this is making unneccessary output in terminal btw
}

### PROCESS HSK
$hskpath = ".\\hsk4.txt", '.\hsk5.txt', '.\hsk6.txt'
$hskoutpath = ".\\hsk4_Output.txt", '.\hsk5_Output.txt', '.\hsk6_Output.txt'

# get each hsk text
$files = New-Object System.Collections.Generic.List"[String[]]";
For ($i = 0; $i -lt 3; $i++) {
    $content = Get-Content -Path $hskpath[$i];
    $files.Add($content);
}

# add words from each hsk to output
For ($i = 0; $i -lt 3; $i++) {
    For ($j = 0; $j -lt $files[$i].Length; $j++) {
        $line = $files[$i][$j];
        # split tokens
        $tokens = $line.Split();
        # if we doesn't exist in yabla vocab
        if (!$yablaList.Contains($tokens[1])) {
            Out-File -FilePath $hskoutpath[$i] -InputObject $line -Append;
        }
    }
}