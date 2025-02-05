
write-verbose "Start module import dlipxelib $PSScriptRoot"
get-childitem -path "$PSScriptRoot\*.ps1" -recurse -exclude *.tests.ps1,*.templates.ps1 | %{
    write-verbose "Importing function $($_.FullName)"
    . $_.FullName | out-null
}

Export-ModuleMember -function * -alias *