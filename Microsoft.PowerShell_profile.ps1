function grep{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$expression,
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [String]$dir_path,
        [Parameter()]
        [String]$dummy
        )
    Process{
        Select-String $expression $dir_path
    }
};
function grep_find{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [String]$dir_path,
        [Parameter(Mandatory=$true)]
        [String]$filter,
        [Parameter(Mandatory=$true)]
        [String]$expression,
        [Parameter()]
        [String]$dummy
        )
    Process{
        ls -r $dir_path | Where-Object{$_.Name -like $filter} | Select-String $expression 
    }
};
function my_diff_file{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [String]$file_0,
        [Parameter(Mandatory=$true)]
        [String]$file_1,
    	[Parameter()]
        [AllowNull()]
        [String]$enc_0,
	    [Parameter()]
        [AllowNull()]
        [String]$enc_1
    )
    Process{
    $exec = "Compare-Object $(Get-Content "
	if( $enc_0){
        $exec += " -Encoding " + $enc_0
    }
    $exec += " " + $file_0 + ") $(Get-Content"
    if( $enc_1){
        $exec += " -Encoding " + $enc_1
    }
    $exec += " " + $file_1 +")"
    Invoke-Expression $exec
    }
};

function Global:Convert-HString{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyname=$true)]
    [String]$HString
)
Begin{
    Write-Verbose "Converting Here-String to Array"
}
Process{
     $HString -split "`n" | ForEach-Object{
        $ComputerName = $_.trim()
        if($ComputerName -notmatch "#"){
            $ComputerName
        }
    }
}
End{
    #Nothing
}
};

function Global:zip{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
        [switch]$mX0,
    [Parameter(Mandatory=$false)]
        [switch]$rmTq,
    [Parameter(Mandatory=$true)]
        [String]$dst,
    [Parameter(Mandatory=$true)]
        [String]$src
)
Begin{
    Write-Verbose "Bridege Compress-Archive to zip"
}
Process{
    $exec = "Compress-Archive -DestinationPath " + $dst 
    if( $rmTq  -and $src.Equals(".")){
        $exec = " ls | Where-Object {$_.Name -ne `"" + $dst + "`"} | "+ $exec
    }else{
        $exec += " -Path " + $src 
    }
    if( $mX0 -or $rmTq ){
        $exec  += " -Update "
    }

    Invoke-Expression $exec
}
End{
    #Nothing
}
};

function Global:find{
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false, Position=1)]
    [String]$dirPath,
    [Parameter(Mandatory=$false, Position=2)]
    [String]$defaultName,
    [Parameter(Mandatory=$false)]
    [String]$name,
    [Parameter(Mandatory=$false)]
    [String]$iname,
    [Parameter(Mandatory=$false)]
    [String]$type,
    [Parameter(Mandatory=$false)]
    [switch]$empty,        
    [Parameter(Mandatory=$false)]
    [String]$exec
)
    Begin{
	Write-Verbose "UNIX find like"
    }
    Process{
	if($dirPath -eq $null -or $dirPath -eq ""){
	    $tPath = "."
	}else{
	    $tPath = $dirPath
	}

	if(($name -eq $null -or $name -eq "") -and ($iname -eq $null -or $iname -eq "")){
	    $tName = $defaultName
	}elseif($name -ne $null -and $name -ne "" ){
	    $tName = $name
	}elseif($iname -ne $null -and $iname -ne "" ){
	    $tName = $iname
	}else {
	    $tName = ""
	}

	$tCond = ""
	if($type -eq "d"){
	    $tCond += " -and `$_.PSisContainer"
	}elseif($type -eq "f"){
	    $tCond += " -and -not `$_.PSisContainer"
	}

	if($empty){
	    $emptyDir = "(!`$_.GetFiles().Count -and
  !`$_.GetDirectories().Count)"
	    $emptyFile = "((get-content `$_.FullName | measure-object).count -lt 2)"
	    if($type -eq "d"){
		$tCond += " -and " + $emptyDir
	    }elseif($type -eq "f"){
		$tCond += " -and " + $emptyFile
	    }else {
		$tCond += " -and ((-not `$_.PSisContainer -and" + $emptyFile + ") -or (`$_.PSisContainer -and " + $emptyDir + "))"
	    }
	}
	
	$exec = "ls -r {0} | Where-Object {{`$_.Name -match `"{1}`" {2}}} | Select -ExpandProperty  FullName" -f $tPath, $tName, $tCond
#	Write-Output ("`$exec : " + $exec)
	Invoke-Expression $exec
    }
    End{
	#Nothing
    }
};

