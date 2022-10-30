# MAP SENTENCES TO YABLA VOCAB
<#
ITERATE THROUGH ALL SENTENCES:
    IF IT IS HANZI:
        CAN WE FIND ANY OF THESE WORDS FROM THE SENTENCE IN OUR YABLA VOCAB DICT?
        MAP YABLA VOCAB TO A LIST OF SENTENCES

HOW DO WE RECOGNIZE A WORD?
TRY 1 CHAR, 2 CHAR, 3 CHAR, 4 CHAR?

BOTH TEXT FILES WE WANT TO PARSE HAVE DIFFERENT FORMATS

transcripts
374825	cmn	Latn	sadhen	Xie4xie5 ni3.
0       1   2        3        4

cmn sentences
11	cmn	我不知道應該說什麼才好。
0   1   2

Later we may need to consider a priority for sentences ...or not
so we change the list into List[Tuple[priority,word]]
then we sort it
give higher priority to better dramas...
but probably will only bother getting from best dramas...so maybe just add to front of list
#>

### PROCESS YABLA VOCAB
# input yabla vocab text
$file = Get-Content -Path .\yablaVocab.txt

# <word, subtlex count>
$yablaDict = New-Object System.Collections.Generic.Dictionary"[String,List[String]]"

$range = [int]('A'), [int]('Z'), [int]('a'), [int]('z')

# iterate yabla
For ($i = 0; $i -lt $file.Length; $i += 2) {
    # split tokens
    $yablaWord = $file[$i].Split()[0];
    # add yabla words to dict
    if (!$yablaDict.ContainsKey($yablaWord)) {
        $list = New-Object System.Collections.Generic.List"[String]";
        $yablaDict.Add($yablaWord, $list);
    }
}

# PARSE FILES
$files = Get-Content -Path .\cmn_sentences.tsv, Get-Content -Path .\cmn_transcriptions.tsv
$tokenNdx = 2, 4

# for each file
For ($i = 0; $i -lt $files.Length; $i++) {
    # for each line
    For ($j = 0; $j -lt $files[$i].Length; $j++) {
        # split tokens
        $tokens = $file[$i][$j].Split();
        $sentence = $tokens[$tokenNdx[$i]];
        # to avoid adding this sentence to the same word's list multiple times
        $found = New-Object 'System.Collections.Generic.HashSet[String]'
        # parse char by char
        For ($k = 0; $k -lt $sentence.Length; $k++) {
            $ch = $sentence[$k];

            #### check if found here....

            # reject sentences with latin chars
            $ascii = [int]$ch - 97;
            if (($ascii -ge $range[0] && $ascii -le $range[1])
                || ($ascii -ge $range[2] && $ascii -le $range[3])) {
                break;
            }
            # check dict for individual char
            if ($yablaDict.ContainsKey($ch)) {
                # add to mapped elem's list
                $yablaDict[$ch].Add($sentence);
                $found.Add($ch);
            }
        }
        # parse groups
        For ($gSize = 2; $gSize -lt 5; $gSize++) {
            For ($k = 0; $k -lt $sentence.Length - ($gSize - 1); $k++) {
                # consider substring starting at $k

                #### basically follow same ideas as above
            }
        }
    }
}

