# Takes whatever images are in this folder
# Renames them according to user input hanzi
# Moves them to other folder with other processed images

### REPEATEDLY PROMPT FOR HANZI
do {
    $hanzi = Read-Host -Prompt "Hanzi:"

    ### RENAME IMAGES
    $imgTypes = "*.png", "*.jpg", "*.jpeg", "*.gif", "*.bmp"
    $count = 0;
    
    $imgTypes | ForEach-Object -Process {
        $type = $_
        Get-ChildItem $type | ForEach-Object -Process {
            $count += 1;
            $_ | Rename-Item -NewName {
                $hanzi + " " + ($count).ToString() + $type.Substring(1);
            }
        }
    }

    ### MOVE IMAGES
    # for each image type
    $imgTypes | ForEach-Object -Process {
        Get-ChildItem $_ | Move-Item -Destination ".\processed"
    }
    
} while (1)

