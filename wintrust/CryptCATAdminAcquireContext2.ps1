﻿function CryptCATAdminAcquireContext2
{
    <#
    .SYNOPSIS

    The CryptCATAdminAcquireContext2 function acquires a handle to a catalog administrator context for a given hash algorithm and hash policy.

    You can use this handle in subsequent calls to the following functions:
    - CryptCATAdminAddCatalog
    - CryptCATAdminEnumCatalogFromHash
    - CryptCATAdminRemoveCatalog

    .PARAMETER Subsystem

    A pointer to the GUID that identifies the subsystem. DRIVER_ACTION_VERIFY represents the subsystem for operating system components and third party drivers. This is the subsystem used by most implementations.
    
    .NOTES

    Author: Jared Atkinson (@jaredcatkinson)
    License: BSD 3-Clause
    Required Dependencies: PSReflect, CERT_STRONG_SIGN_PARA (Structure)
    Optional Dependencies: None
    
    (func wintrust CryptCATAdminAcquireContext2 ([bool]) @(
      [IntPtr].MakeByRefType(), #_Out_            HCATADMIN               *phCatAdmin
      [Guid].MakeByRefType(),   #_In_       const GUID                    *pgSubsystem
      [IntPtr],                 #_In_opt_         PCWSTR                  pwszHashAlgorithm
      [IntPtr],                 #_In_opt_         PCCERT_STRONG_SIGN_PARA pStrongHashPolicy
      [UInt32]                  #_In_             DWORD                   dwFlags        
    ) -EntryPoint CryptCATAdminAcquireContext2 -SetLastError)

    .LINK

    https://msdn.microsoft.com/en-us/library/windows/desktop/aa379889(v=vs.85).aspx

    .EXAMPLE
    #>

    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('DRIVER_ACTION_VERIFY','HTTPSPROV_ACTION','OFFICESIGN_ACTION_VERIFY','WINTRUST_ACTION_GENERIC_CHAIN_VERIFY','WINTRUST_ACTION_GENERIC_VERIFY_V2','WINTRUST_ACTION_TRUSTPROVIDER_TEST')]
        [string]
        $Subsystem,

        [Parameter()]
        [ValidateSet('SHA1','SHA256')]
        [string]
        $HashAlgorithm = 'SHA1'
    )

    $phCatAdmin = [IntPtr]::Zero

    switch($Subsystem)
    {
        DRIVER_ACTION_VERIFY {$pgSubsystem = [Guid]::new('F750E6C3-38EE-11d1-85E5-00C04FC295EE'); break}
        HTTPSPROV_ACTION {$pgSubsystem = [Guid]::new('573E31F8-AABA-11d0-8CCB-00C04FC295EE'); break}
        OFFICESIGN_ACTION_VERIFY {$pgSubsystem = [Guid]::new('5555C2CD-17FB-11d1-85C4-00C04FC295EE'); break}
        WINTRUST_ACTION_GENERIC_CHAIN_VERIFY {$pgSubsystem = [Guid]::new('fc451c16-ac75-11d1-b4b8-00c04fb66ea0'); break}
        WINTRUST_ACTION_GENERIC_VERIFY_V2 {$pgSubsystem = [Guid]::new('00AAC56B-CD44-11d0-8CC2-00C04FC295EE'); break}
        WINTRUST_ACTION_TRUSTPROVIDER_TEST {$pgSubsystem = [Guid]::new('573E31F8-DDBA-11d0-8CCB-00C04FC295EE'); break}
    }

    $pwszHashAlgorithm = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($HashAlgorithm)

    $SUCCESS = $wintrust::CryptCATAdminAcquireContext2([ref]$phCatAdmin, [ref]$pgSubsystem, $pwszHashAlgorithm, [IntPtr]::Zero, 0); $LastError = [Runtime.InteropServices.Marshal]::GetLastWin32Error()

    if(-not $SUCCESS) 
    {
        throw "[CryptCATAdminAcquireContext2] Error: $(([ComponentModel.Win32Exception] $LastError).Message)"
    }

    Write-Output $phCatAdmin
}