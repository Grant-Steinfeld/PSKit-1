﻿Add-Type -Path "$PSScriptRoot\lib\MathNet.Numerics.dll"

. $PSScriptRoot/ConvertFromFixedData.ps1
. $PSScriptRoot/ConvertFromSSV.ps1
. $PSScriptRoot/ConvertIntoCSV.ps1
. $PSScriptRoot/CustomTypeData.ps1
. $PSScriptRoot/GenerateStats.ps1
. $PSScriptRoot/GetDataInfo.ps1
. $PSScriptRoot/GetDataTypePrecedence.ps1
. $PSScriptRoot/GetDateRange.ps1
. $PSScriptRoot/GetPropertyName.ps1
. $PSScriptRoot/GetPropertyStats.ps1
. $PSScriptRoot/GroupByAndMeasure.ps1
. $PSScriptRoot/InferData.ps1
. $PSScriptRoot/InvokeTranspileSQL.ps1
. $PSScriptRoot/NewDataframe.ps1
. $PSScriptRoot/NewLookupTable.ps1
. $PSScriptRoot/ReadCsv.ps1
. $PSScriptRoot/ScanProperties.ps1

filter ConvertTo-Property {
    $i = $_
    "" | Select-Object @{n = "P1"; e = { $i } }
}

function Script:Test-JupyterNotebook {
    if (Get-Command Out-Display -ErrorAction SilentlyContinue) {
        $true
    }
    else {
        $false
    }
}

# Added here, just for PS Jupyter Notebooks. May move elsewhere.
if (Test-JupyterNotebook) {
    function ConvertTo-MarkdownTable {
        param(
            [parameter(ValueFromPipeline)]
            $targetData
        )

        Begin { $allData = @() }

        Process {
            # $allData += $targetData
            if ($targetData.gettype().name -match 'HashTable|OrderedDictionary') {
                $allData = [PSCustomObject]$targetData
            }
            else {
                $allData += $targetData
            }
        }

        End {
            $names = $allData[0].psobject.Properties.name

            $result = foreach ($record in $allData) {
                $inner = @()
                foreach ($name in $names) {
                    $inner += $record.$name
                }
                '|' + ($inner -join '|') + '|' + "`n"
            }

            $html = (@"
$('|' + ($names -join '|') + '|')
$(('|---' * ($names.Count - 1)) + '|')
$($result)
"@ | ConvertFrom-Markdown).html

            if (Get-Command Get-HtmlContent -ErrorAction SilentlyContinue) {
                $html | Get-HtmlContent | Out-Display
            }
            else {
                $html | Out-Display
            }
        }
    }

    Set-Alias ctmt ConvertTo-MarkdownTable
}