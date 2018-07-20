function Add-WordTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.Container] $WordDocument,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.InsertBeforeOrAfter] $Paragraph,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.InsertBeforeOrAfter] $Table,
        [ValidateNotNullOrEmpty()]$DataTable,
        [AutoFit] $AutoFit,
        [TableDesign] $Design,
        [Direction] $Direction,
        [switch] $BreakPageAfterTable,
        [switch] $BreakPageBeforeTable,
        [nullable[bool]] $BreakAcrossPages,
        [int] $MaximumColumns = 5,
        [string[]]$Titles = @('Name', 'Value'),
        [switch] $DoNotAddTitle,
        [float[]] $ColummnWidth = @(),
        [nullable[float]] $TableWidth = $null,
        [bool] $Percentage,

        [alias ("C")] [System.Drawing.Color[]]$Color = @(),
        [alias ("S")] [double[]] $FontSize = @(),
        [alias ("FontName")] [string[]] $FontFamily = @(),
        [alias ("B")] [nullable[bool][]] $Bold = @(),
        [alias ("I")] [nullable[bool][]] $Italic = @(),
        [alias ("U")] [UnderlineStyle[]] $UnderlineStyle = @(),
        [alias ('UC')] [System.Drawing.Color[]]$UnderlineColor = @(),
        [alias ("SA")] [double[]] $SpacingAfter = @(),
        [alias ("SB")] [double[]] $SpacingBefore = @(),
        [alias ("SP")] [double[]] $Spacing = @(),
        [alias ("H")] [highlight[]] $Highlight = @(),
        [alias ("CA")] [CapsStyle[]] $CapsStyle = @(),
        [alias ("ST")] [StrikeThrough[]] $StrikeThrough = @(),
        [alias ("HT")] [HeadingType[]] $HeadingType = @(),
        [int[]] $PercentageScale = @(), # "Value must be one of the following: 200, 150, 100, 90, 80, 66, 50 or 33"
        [Misc[]] $Misc = @(),
        [string[]] $Language = @(),
        [int[]]$Kerning = @(), # "Value must be one of the following: 8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48 or 72"
        [nullable[bool][]]$Hidden = @(),
        [int[]]$Position = @(), #  "Value must be in the range -1585 - 1585"
        [single[]] $IndentationFirstLine = @(),
        [single[]] $IndentationHanging = @(),
        [Alignment[]] $Alignment = @(),
        [Direction[]] $DirectionFormatting = @(),
        [ShadingType[]] $ShadingType = @(),
        [Script[]] $Script = @(),

        [nullable[bool][]] $NewLine = @(),
        [switch] $KeepLinesTogether,
        [switch] $KeepWithNextParagraph,
        [switch]$ContinueFormatting,
        [bool] $Supress = $true
    )
    $DataTable = Convert-ObjectToProcess -DataTable $DataTable
    $ObjectType = $DataTable.GetType().Name


    ### Prepare Number of ROWS/COLUMNS
    if ($ObjectType -eq 'Hashtable' -or $ObjectType -eq 'OrderedDictionary') {
        $NumberRows = $DataTable.Count + 1
        $NumberColumns = 2
        Write-Verbose 'Add-WordTable - Option 1'
        Write-Verbose "Add-WordTable - Column Count $($NumberColumns) Rows Count $NumberRows "
        Write-Verbose "Add-WordTable - Titles: $([string] $Titles)"
    } elseif ($ObjectType -eq 'PSCustomObject') {
        $Columns = Get-ObjectTitles -Object $DataTable[0]
        $NumberRows = $Columns.Count + 1
        $NumberColumns = 2
        Write-Verbose 'Add-WordTable - Option 2'
        Write-Verbose "Add-WordTable - Column Count $($NumberColumns) Rows Count $NumberRows "
        Write-Verbose "Add-WordTable - Titles: $([string] $Titles)"
    } elseif ($DataTable.GetType().Name -eq 'Object[]') {
        $Titles = Get-ObjectTitles -Object $DataTable[0]
        $NumberColumns = if ($Titles.Count -ge $MaximumColumns) { $MaximumColumns } else { $Titles.Count }
        $NumberRows = $DataTable.Count + 1
        write-verbose 'Add-WordTable - option 3'
        Write-Verbose "Add-WordTable - DoNotAddTitle $DoNotAddTitle (Option 3)"
        Write-Verbose "Add-WordTable - Column Count $($NumberColumns) Rows Count $NumberRows "
        Write-Verbose "Add-WordTable - Titles: $([string] $Titles)"
    } else {
        $pattern = 'string|bool|byte|char|decimal|double|float|int|long|sbyte|short|uint|ulong|ushort'
        $Titles = ($DataTable | Get-Member | Where-Object { $_.MemberType -like "*Property" -and $_.Definition -match $pattern }) | Select-Object Name
        $NumberColumns = if ($Titles.Count -ge $MaximumColumns) { $MaximumColumns } else { $Titles.Count }
        $NumberRows = $DataTable.Count
        Write-Verbose 'Add-WordTable - Option 4'
        Write-Verbose "Add-WordTable - Column Count $($NumberColumns) Rows Count $NumberRows "
    }
    ### Add Table or Add To TABLE
    if ($Table -eq $null) {
        $Table = New-WordTable -WordDocument $WordDocument -Paragraph $Paragraph -NrRows $NumberRows -NrColumns $NumberColumns -Supress $false
    } else {
        Add-WordTableRow -Table $Table -Count $DataTable.Count
    }
    ### Add titles
    if (-not $DoNotAddTitle) {
        Add-WordTableTitle -Title $Titles `
            -Table $Table `
            -MaximumColumns $MaximumColumns `
            -Color $Color[0] `
            -FontSize $FontSize[0] `
            -FontFamily $FontFamily[0] `
            -Bold $Bold[0] `
            -Italic $Italic[0] `
            -UnderlineStyle $UnderlineStyle[0] `
            -UnderlineColor $UnderlineColor[0] `
            -SpacingAfter $SpacingAfter[0] `
            -SpacingBefore $SpacingBefore[0] `
            -Spacing $Spacing[0] `
            -Highlight $Highlight[0] `
            -CapsStyle $CapsStyle[0] `
            -StrikeThrough $StrikeThrough[0] `
            -HeadingType $HeadingType[0] `
            -PercentageScale $PercentageScale[0] `
            -Misc $Misc[0] `
            -Language $Language[0] `
            -Kerning $Kerning[0] `
            -Hidden $Hidden[0] `
            -Position $Position[0] `
            -IndentationFirstLine $IndentationFirstLine[0] `
            -IndentationHanging $IndentationHanging[0] `
            -Alignment $Alignment[0] `
            -DirectionFormatting $DirectionFormatting[0] `
            -ShadingType $ShadingType[0] `
            -Script $Script[0]
    }
    ### Continue formatting
    if ($ContinueFormatting -eq $true) {
        $Formatting = Set-WordContinueFormatting -Count $NumberRows `
            -Color $Color `
            -FontSize $FontSize `
            -FontFamily $FontFamily `
            -Bold $Bold `
            -Italic $Italic `
            -UnderlineStyle $UnderlineStyle `
            -UnderlineColor $UnderlineColor `
            -SpacingAfter $SpacingAfter `
            -SpacingBefore $SpacingBefore `
            -Spacing $Spacing `
            -Highlight $Highlight `
            -CapsStyle $CapsStyle `
            -StrikeThrough $StrikeThrough `
            -HeadingType $HeadingType `
            -PercentageScale $PercentageScale `
            -Misc $Misc `
            -Language $Language `
            -Kerning $Kerning `
            -Hidden $Hidden `
            -Position $Position `
            -IndentationFirstLine $IndentationFirstLine `
            -IndentationHanging $IndentationHanging `
            -Alignment $Alignment `
            -DirectionFormatting $DirectionFormatting `
            -ShadingType $ShadingType `
            -Script $Script

        $Color = $Formatting[0]
        $FontSize = $Formatting[1]
        $FontFamily = $Formatting[2]
        $Bold = $Formatting[3]
        $Italic = $Formatting[4]
        $UnderlineStyle = $Formatting[5]
        $UnderlineColor = $Formatting[6]
        $SpacingAfter = $Formatting[7]
        $SpacingBefore = $Formatting[8]
        $Spacing = $Formatting[9]
        $Highlight = $Formatting[10]
        $CapsStyle = $Formatting[11]
        $StrikeThrough = $Formatting[12]
        $HeadingType = $Formatting[13]
        $PercentageScale = $Formatting[14]
        $Misc = $Formatting[15]
        $Language = $Formatting[16]
        $Kerning = $Formatting[17]
        $Hidden = $Formatting[18]
        $Position = $Formatting[19]
        $IndentationFirstLine = $Formatting[20]
        $IndentationHanging = $Formatting[21]
        $Alignment = $Formatting[22]
        $DirectionFormatting = $Formatting[23]
        $ShadingType = $Formatting[24]
        $Script = $Formatting[25]
    }
    ###  Build data in Table
    if ($ObjectType -eq 'Hashtable' -or $ObjectType -eq 'OrderedDictionary') {
        Write-Verbose 'Add-WordTable - Option 1'
        $RowNr = 1
        foreach ($TableEntry in $DataTable.GetEnumerator()) {
            $ColumnNrForTitle = 0
            $ColumnNrForData = 1
            $Data = Add-WordTableCellValue -Table $Table -Row $RowNr -Column $ColumnNrForTitle -Value $TableEntry.Name `
                -Color $Color[$RowNr] `
                -FontSize $FontSize[$RowNr] `
                -FontFamily $FontFamily[$RowNr] `
                -Bold $Bold[$RowNr] `
                -Italic $Italic[$RowNr] `
                -UnderlineStyle $UnderlineStyle[$RowNr]`
                -UnderlineColor $UnderlineColor[$RowNr]`
                -SpacingAfter $SpacingAfter[$RowNr] `
                -SpacingBefore $SpacingBefore[$RowNr] `
                -Spacing $Spacing[$RowNr] `
                -Highlight $Highlight[$RowNr] `
                -CapsStyle $CapsStyle[$RowNr] `
                -StrikeThrough $StrikeThrough[$RowNr] `
                -HeadingType $HeadingType[$RowNr] `
                -PercentageScale $PercentageScale[$RowNr] `
                -Misc $Misc[$RowNr] `
                -Language $Language[$RowNr]`
                -Kerning $Kerning[$RowNr]`
                -Hidden $Hidden[$RowNr]`
                -Position $Position[$RowNr]`
                -IndentationFirstLine $IndentationFirstLine[$RowNr]`
                -IndentationHanging $IndentationHanging[$RowNr]`
                -Alignment $Alignment[$RowNr]`
                -DirectionFormatting $DirectionFormatting[$RowNr] `
                -ShadingType $ShadingType[$RowNr]`
                -Script $Script[$RowNr]
            $Data = Add-WordTableCellValue -Table $Table -Row $RowNr -Column $ColumnNrForData -Value $TableEntry.Value `
                -Color $Color[$RowNr] `
                -FontSize $FontSize[$RowNr] `
                -FontFamily $FontFamily[$RowNr] `
                -Bold $Bold[$RowNr] `
                -Italic $Italic[$RowNr] `
                -UnderlineStyle $UnderlineStyle[$RowNr]`
                -UnderlineColor $UnderlineColor[$RowNr]`
                -SpacingAfter $SpacingAfter[$RowNr] `
                -SpacingBefore $SpacingBefore[$RowNr] `
                -Spacing $Spacing[$RowNr] `
                -Highlight $Highlight[$RowNr] `
                -CapsStyle $CapsStyle[$RowNr] `
                -StrikeThrough $StrikeThrough[$RowNr] `
                -HeadingType $HeadingType[$RowNr] `
                -PercentageScale $PercentageScale[$RowNr] `
                -Misc $Misc[$RowNr] `
                -Language $Language[$RowNr]`
                -Kerning $Kerning[$RowNr]`
                -Hidden $Hidden[$RowNr]`
                -Position $Position[$RowNr]`
                -IndentationFirstLine $IndentationFirstLine[$RowNr]`
                -IndentationHanging $IndentationHanging[$RowNr]`
                -Alignment $Alignment[$RowNr]`
                -DirectionFormatting $DirectionFormatting[$RowNr] `
                -ShadingType $ShadingType[$RowNr]`
                -Script $Script[$RowNr]
            Write-Verbose "Add-WordTable - RowNr: $RowNr / ColumnNr: $ColumnTitle Name: $($TableEntry.Name) Value: $($TableEntry.Value)"
            $RowNr++

        }
    } elseif ($ObjectType -eq 'PSCustomObject') {
        Write-Verbose 'Add-WordTable - Option 2'
        $RowNr = 1
        foreach ($Title in $Columns) {
            $Value = Get-ObjectData -Object $DataTable -Title $Title -DoNotAddTitles
            $ColumnTitle = 0
            $ColumnData = 1
            $Data = Add-WordTableCellValue -Table $Table -Row $RowNr -Column $ColumnTitle -Value $Title `
                -Color $Color[$RowNr] `
                -FontSize $FontSize[$RowNr] `
                -FontFamily $FontFamily[$RowNr] `
                -Bold $Bold[$RowNr] `
                -Italic $Italic[$RowNr] `
                -UnderlineStyle $UnderlineStyle[$RowNr]`
                -UnderlineColor $UnderlineColor[$RowNr]`
                -SpacingAfter $SpacingAfter[$RowNr] `
                -SpacingBefore $SpacingBefore[$RowNr] `
                -Spacing $Spacing[$RowNr] `
                -Highlight $Highlight[$RowNr] `
                -CapsStyle $CapsStyle[$RowNr] `
                -StrikeThrough $StrikeThrough[$RowNr] `
                -HeadingType $HeadingType[$RowNr] `
                -PercentageScale $PercentageScale[$RowNr] `
                -Misc $Misc[$RowNr] `
                -Language $Language[$RowNr]`
                -Kerning $Kerning[$RowNr]`
                -Hidden $Hidden[$RowNr]`
                -Position $Position[$RowNr]`
                -IndentationFirstLine $IndentationFirstLine[$RowNr]`
                -IndentationHanging $IndentationHanging[$RowNr]`
                -Alignment $Alignment[$RowNr]`
                -DirectionFormatting $DirectionFormatting[$RowNr] `
                -ShadingType $ShadingType[$RowNr]`
                -Script $Script[$RowNr]

            $Data = Add-WordTableCellValue -Table $Table -Row $RowNr -Column $ColumnData -Value $Value `
                -Color $Color[$RowNr] `
                -FontSize $FontSize[$RowNr] `
                -FontFamily $FontFamily[$RowNr] `
                -Bold $Bold[$RowNr] `
                -Italic $Italic[$RowNr] `
                -UnderlineStyle $UnderlineStyle[$RowNr]`
                -UnderlineColor $UnderlineColor[$RowNr]`
                -SpacingAfter $SpacingAfter[$RowNr] `
                -SpacingBefore $SpacingBefore[$RowNr] `
                -Spacing $Spacing[$RowNr] `
                -Highlight $Highlight[$RowNr] `
                -CapsStyle $CapsStyle[$RowNr] `
                -StrikeThrough $StrikeThrough[$RowNr] `
                -HeadingType $HeadingType[$RowNr] `
                -PercentageScale $PercentageScale[$RowNr] `
                -Misc $Misc[$RowNr] `
                -Language $Language[$RowNr]`
                -Kerning $Kerning[$RowNr]`
                -Hidden $Hidden[$RowNr]`
                -Position $Position[$RowNr]`
                -IndentationFirstLine $IndentationFirstLine[$RowNr]`
                -IndentationHanging $IndentationHanging[$RowNr]`
                -Alignment $Alignment[$RowNr]`
                -DirectionFormatting $DirectionFormatting[$RowNr] `
                -ShadingType $ShadingType[$RowNr]`
                -Script $Script[$RowNr]

            Write-Verbose "Add-WordTable - Title:  $Title Value: $Value Row: $RowNr "
            $RowNr++

        }
    } elseif ($DataTable.GetType().Name -eq 'Object[]') {
        write-verbose 'Add-WordTable - option 3'
        Write-Verbose "Add-WordTable - Process Data (Option3)"
        for ($b = 0; $b -lt $NumberRows - 1; $b++) {
            $ColumnNr = 0
            foreach ($Title in $Titles) {

                $RowNr = $($b + 1)
                $Value = $DataTable[$b].$Title
                $Data = Add-WordTableCellValue -Table $Table -Row $RowNr -Column $ColumnNr -Value $Value `
                    -Color $Color[$RowNr] `
                    -FontSize $FontSize[$RowNr] `
                    -FontFamily $FontFamily[$RowNr] `
                    -Bold $Bold[$RowNr] `
                    -Italic $Italic[$RowNr] `
                    -UnderlineStyle $UnderlineStyle[$RowNr]`
                    -UnderlineColor $UnderlineColor[$RowNr]`
                    -SpacingAfter $SpacingAfter[$RowNr] `
                    -SpacingBefore $SpacingBefore[$RowNr] `
                    -Spacing $Spacing[$RowNr] `
                    -Highlight $Highlight[$RowNr] `
                    -CapsStyle $CapsStyle[$RowNr] `
                    -StrikeThrough $StrikeThrough[$RowNr] `
                    -HeadingType $HeadingType[$RowNr] `
                    -PercentageScale $PercentageScale[$RowNr] `
                    -Misc $Misc[$RowNr] `
                    -Language $Language[$RowNr]`
                    -Kerning $Kerning[$RowNr]`
                    -Hidden $Hidden[$RowNr]`
                    -Position $Position[$RowNr]`
                    -IndentationFirstLine $IndentationFirstLine[$RowNr]`
                    -IndentationHanging $IndentationHanging[$RowNr]`
                    -Alignment $Alignment[$RowNr]`
                    -DirectionFormatting $DirectionFormatting[$RowNr] `
                    -ShadingType $ShadingType[$RowNr]`
                    -Script $Script[$RowNr]

                if ($ColumnNr -eq $($MaximumColumns - 1)) { break; } # prevents display of more columns then there is space, choose carefully
                $ColumnNr++
            }
        }
    } else {
        Write-Verbose 'Add-WordTable - Option 4'

        for ($RowNr = 1; $RowNr -lt $NumberRows; $RowNr++) {
            $ColumnNr = 0
            foreach ($Title in $Titles.Name) {
                $Value = $DataTable[$RowNr].$Title
                $Data = Add-WordTableCellValue -Table $Table `
                    -Row $RowNr `
                    -Column $ColumnNr `
                    -Value $Value `
                    -Color $Color[$RowNr] `
                    -FontSize $FontSize[$RowNr] `
                    -FontFamily $FontFamily[$RowNr] `
                    -Bold $Bold[$RowNr] `
                    -Italic $Italic[$RowNr] `
                    -UnderlineStyle $UnderlineStyle[$RowNr]`
                    -UnderlineColor $UnderlineColor[$RowNr]`
                    -SpacingAfter $SpacingAfter[$RowNr] `
                    -SpacingBefore $SpacingBefore[$RowNr] `
                    -Spacing $Spacing[$RowNr] `
                    -Highlight $Highlight[$RowNr] `
                    -CapsStyle $CapsStyle[$RowNr] `
                    -StrikeThrough $StrikeThrough[$RowNr] `
                    -HeadingType $HeadingType[$RowNr] `
                    -PercentageScale $PercentageScale[$RowNr] `
                    -Misc $Misc[$RowNr] `
                    -Language $Language[$RowNr]`
                    -Kerning $Kerning[$RowNr]`
                    -Hidden $Hidden[$RowNr]`
                    -Position $Position[$RowNr]`
                    -IndentationFirstLine $IndentationFirstLine[$RowNr]`
                    -IndentationHanging $IndentationHanging[$RowNr]`
                    -Alignment $Alignment[$RowNr]`
                    -DirectionFormatting $DirectionFormatting[$RowNr] `
                    -ShadingType $ShadingType[$RowNr]`
                    -Script $Script[$RowNr]

                if ($ColumnNr -eq $($MaximumColumns - 1)) { break; } # prevents display of more columns then there is space, choose carefully
                $ColumnNr++
            }
        }

    }
    ### Apply formatting to table
    $Table | Set-WordTableColumnWidth -Width $ColummnWidth -TotalWidth $TableWidth -Percentage $Percentage
    $Table | Set-WordTable -Direction $Direction `
        -AutoFit $AutoFit `
        -Design $Design `
        -BreakPageAfterTable:$BreakPageAfterTable `
        -BreakPageBeforeTable:$BreakPageBeforeTable `
        -BreakAcrossPages $BreakAcrossPages
    ### return data
    if ($Supress -eq $false) { return $Table } else { return }
}

function Set-WordContinueFormatting {
    param(
        [int] $Count,
        [alias ("C")] [System.Drawing.Color[]]$Color = @(),
        [alias ("S")] [double[]] $FontSize = @(),
        [alias ("FontName")] [string[]] $FontFamily = @(),
        [alias ("B")] [nullable[bool][]] $Bold = @(),
        [alias ("I")] [nullable[bool][]] $Italic = @(),
        [alias ("U")] [UnderlineStyle[]] $UnderlineStyle = @(),
        [alias ('UC')] [System.Drawing.Color[]]$UnderlineColor = @(),
        [alias ("SA")] [double[]] $SpacingAfter = @(),
        [alias ("SB")] [double[]] $SpacingBefore = @(),
        [alias ("SP")] [double[]] $Spacing = @(),
        [alias ("H")] [highlight[]] $Highlight = @(),
        [alias ("CA")] [CapsStyle[]] $CapsStyle = @(),
        [alias ("ST")] [StrikeThrough[]] $StrikeThrough = @(),
        [alias ("HT")] [HeadingType[]] $HeadingType = @(),
        [int[]] $PercentageScale = @(), # "Value must be one of the following: 200, 150, 100, 90, 80, 66, 50 or 33"
        [Misc[]] $Misc = @(),
        [string[]] $Language = @(),
        [int[]]$Kerning = @(), # "Value must be one of the following: 8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 26, 28, 36, 48 or 72"
        [nullable[bool][]]$Hidden = @(),
        [int[]]$Position = @(), #  "Value must be in the range -1585 - 1585"
        [single[]] $IndentationFirstLine = @(),
        [single[]] $IndentationHanging = @(),
        [Alignment[]] $Alignment = @(),
        [Direction[]] $DirectionFormatting = @(),
        [ShadingType[]] $ShadingType = @(),
        [Script[]] $Script = @()
    )
    for ($RowNr = 0; $RowNr -lt $Count; $RowNr++) {
        Write-Verbose "Set-WordContinueFormatting - RowNr: $RowNr / $Count"
        if ($null -eq $Color[$RowNr] -and $null -ne $Color[$RowNr - 1]) { $Color += $Color[$RowNr - 1] }
        if ($null -eq $FontSize[$RowNr] -and $null -ne $FontSize[$RowNr - 1]) {  $FontSize += $FontSize[$RowNr - 1]  }
        if ($null -eq $FontFamily[$RowNr] -and $null -ne $FontFamily[$RowNr - 1]) { $FontFamily += $FontFamily[$RowNr - 1] }
        if ($null -eq $Bold[$RowNr] -and $null -ne $Bold[$RowNr - 1]) {$Bold += $Bold[$RowNr - 1] }
        if ($null -eq $Italic[$RowNr] -and $null -ne $Italic[$RowNr - 1]) { $Italic += $Italic[$RowNr - 1] }
        if ($null -eq $SpacingAfter[$RowNr] -and $null -ne $SpacingAfter[$RowNr - 1]) { $SpacingAfter += $SpacingAfter[$RowNr - 1] }
        if ($null -eq $SpacingBefore[$RowNr] -and $null -ne $SpacingBefore[$RowNr - 1]) { $SpacingBefore += $SpacingBefore[$RowNr - 1] }
        if ($null -eq $Spacing[$RowNr] -and $null -ne $Spacing[$RowNr - 1]) { $Spacing += $Spacing[$RowNr - 1] }
        if ($null -eq $Highlight[$RowNr] -and $null -ne $Highlight[$RowNr - 1]) { $Highlight += $Highlight[$RowNr - 1] }
        if ($null -eq $CapsStyle[$RowNr] -and $null -ne $CapsStyle[$RowNr - 1]) { $CapsStyle += $CapsStyle[$RowNr - 1] }
        if ($null -eq $StrikeThrough[$RowNr] -and $null -ne $StrikeThrough[$RowNr - 1]) { $StrikeThrough += $StrikeThrough[$RowNr - 1] }
        if ($null -eq $HeadingType[$RowNr] -and $null -ne $HeadingType[$RowNr - 1]) { $HeadingType += $HeadingType[$RowNr - 1] }
        if ($null -eq $PercentageScale[$RowNr] -and $null -ne $PercentageScale[$RowNr - 1]) { $PercentageScale += $PercentageScale[$RowNr - 1] }
        if ($null -eq $Misc[$RowNr] -and $null -ne $Misc[$RowNr - 1]) { $Misc += $Misc[$RowNr - 1] }
        if ($null -eq $Language[$RowNr] -and $null -ne $Language[$RowNr - 1]) { $Language += $Language[$RowNr - 1] }
        if ($null -eq $Kerning[$RowNr] -and $null -ne $Kerning[$RowNr - 1]) { $Kerning += $Kerning[$RowNr - 1] }
        if ($null -eq $Hidden[$RowNr] -and $null -ne $Hidden[$RowNr - 1]) { $Hidden += $Hidden[$RowNr - 1] }
        if ($null -eq $Position[$RowNr] -and $null -ne $Position[$RowNr - 1]) { $Position += $Position[$RowNr - 1] }
        if ($null -eq $IndentationFirstLine[$RowNr] -and $null -ne $IndentationFirstLine[$RowNr - 1]) { $IndentationFirstLine += $IndentationFirstLine[$RowNr - 1] }
        if ($null -eq $IndentationHanging[$RowNr] -and $null -ne $IndentationHanging[$RowNr - 1]) { $IndentationHanging += $IndentationHanging[$RowNr - 1] }
        if ($null -eq $Alignment[$RowNr] -and $null -ne $Alignment[$RowNr - 1]) { $Alignment += $Alignment[$RowNr - 1] }
        if ($null -eq $DirectionFormatting[$RowNr] -and $null -ne $DirectionFormatting[$RowNr - 1]) { $DirectionFormatting += $DirectionFormatting[$RowNr - 1] }
        if ($null -eq $ShadingType[$RowNr] -and $null -ne $ShadingType[$RowNr - 1]) { $ShadingType += $ShadingType[$RowNr - 1] }
        if ($null -eq $Script[$RowNr] -and $null -ne $Script[$RowNr - 1]) { $Script += $Script[$RowNr - 1] }
    }

    return @(
        $Color,
        $FontSize,
        $FontFamily,
        $Bold,
        $Italic,
        $UnderlineStyle,
        $UnderlineColor,
        $SpacingAfter,
        $SpacingBefore,
        $Spacing,
        $Highlight,
        $CapsStyle,
        $StrikeThrough,
        $HeadingType,
        $PercentageScale,
        $Misc,
        $Language,
        $Kerning,
        $Hidden,
        $Position,
        $IndentationFirstLine,
        $IndentationHanging,
        $Alignment,
        $DirectionFormatting,
        $ShadingType,
        $Script
    )
}

function Remove-WordTable {
    [CmdletBinding()]
    param (
        [Xceed.Words.NET.InsertBeforeOrAfter] $Table
    )
    if ($Table -ne $null) {
        $Table.Remove()
    }

}
function New-WordTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.Container] $WordDocument,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.InsertBeforeOrAfter] $Paragraph,
        [int] $NrRows,
        [int] $NrColumns,
        [bool] $Supress = $true
    )
    Write-Verbose "New-WordTable - Paragraph $Paragraph"
    Write-Verbose "New-WordTable - NrRows $NrRows NrColumns $NrColumns Supress $supress"
    if ($Paragraph -eq $null) {
        $WordTable = $WordDocument.InsertTable($NrRows, $NrColumns)
    } else {
        $TableDefinition = $WordDocument.AddTable($NrRows, $NrColumns)
        $WordTable = $Paragraph.InsertTableAfterSelf($TableDefinition)
    }
    if ($Supress) { return } else { return $WordTable }
}
function Get-WordTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.Container] $WordDocument,
        [switch] $ListTables,
        [switch] $LastTable,
        [nullable[int]] $TableID
    )
    if ($LastTable) {
        $Tables = $WordDocument.Tables
        $Table = $Tables[$Tables.Count - 1]
        return $Table
    }
    if ($ListTables) {
        return  $WordDocument.Tables
    }
    if ($TableID -ne $null) {
        return $WordDocument.Tables[$TableID]
    }
}
function Copy-WordTable {
    [CmdletBinding()]
    param (
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.Container] $WordDocument,
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Xceed.Words.NET.InsertBeforeOrAfter] $Paragraph,
        $TableFrom
    )
}

<#
public Table AddTable( int rowCount, int columnCount )
public new Table InsertTable( int rowCount, int columnCount )
public new Table InsertTable( int index, Table t )

#>