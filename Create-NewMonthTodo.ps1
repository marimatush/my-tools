param(
    [String] $Path = '.',

    [Parameter(Mandatory = $true)]
    [String] $FileName,

    [Switch] $SkipWeekends
)

<#
.SYNOPSIS
    This script generates a new file with extension .todo and contains a list of calendar days of the next month.

.DESCRIPTION

    This script generates a new file with extension .todo. The file contains a list calendar days of the next months as a todo list template. 
    It's made to work together with Todo++ extension: https://github.com/fabiospampinato/vscode-todo-plus

.PARAMETER Path
    [Optional] Specifies  the location of the file. Default value is the location of the script.

.PARAMETER FileName
    [Mandatory] Specifies the file name.

.PARAMETER SkipWeekends
    [Optional] Specifies whether weekends must be skipped. If this parameter is ignored, all days of the calendar month will be listed in the file.

.OUTPUTS
    The script generates a file with extension .todo of calendar days of the next month and one todo task.

.EXAMPLE
    PS> .\Create-NewMonthTodo.ps1 -FileName "My.todo" -SkipWeekends
    PS> .\Create-NewMonthTodo.ps1 -Path "C:\Mytodos" -FileName "My.todo" -SkipWeekends
    PS > .\Create-NewMonthTodo.ps1 -FileName "My.todo"
#>

# functions
function IsWeekend {
    param (
        [Int] $DayOfTheWeek
    )
    
    if (($DayOfTheWeek -eq 6) -or ($DayOfTheWeek -eq 0)) { return $true } else { return $false };
}

# script body
$ErrorActionPreference = "Stop"

$Content = "";

$nextMonth = ((Get-Date).AddMonths(1)).Month;
$nextMonthText = (Get-Culture).DateTimeFormat.GetMonthName($nextMonth);
$nextYear = ((Get-Date).AddMonths(1)).Year;

$numOfDays = [DateTime]::DaysInMonth($nextYear, $nextMonth);

$Content += "### Todo list for $nextMonthText $nextYear ###`n`n";
for ($i = 1; $i -le $numOfDays; $i++) {
    $dayOfTheWeek = [int](Get-Date -Date "$nextYear-$nextMonth-$i").DayOfWeek;
    if ((-Not $SkipWeekends) -or ($SkipWeekends -and (-Not (IsWeekend($dayOfTheWeek))))) {
        $Day = (Get-Date -Date "$nextYear-$nextMonth-$i").ToLongDateString();
        $Content += "## " + $Day + " ##:`n"
        $Content += "`t" + [char]::ConvertFromUtf32(9744) + " `n`n"
    }
}

$Content += "## Backlog ##:`n"
$Content += "`t" + [char]::ConvertFromUtf32(9744) + " `n`n"

if (!(Test-Path (Join-Path -Path $Path -ChildPath $FileName))) {
    New-Item -Path $Path -Name $FileName -ItemType File -Value $Content
}
else {
    Write-Host "File already exists"
}
