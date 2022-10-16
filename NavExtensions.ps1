function GetNavExtensions {
    $NavExtension =
    @(
        [pscustomobject]@{name = "BaseAppOld"      ; version = '19.0.29894.30696' },
        [pscustomobject]@{name = "BaseApp"         ; version = '19.0.29894.30697' },
        [pscustomobject]@{name = "Common"          ; version = '20.0.10.4' },
        [pscustomobject]@{name = "SalesItem"       ; version = '20.0.10.2' },
        [pscustomobject]@{name = "Representative"  ; version = '20.0.10.4' },
        [pscustomobject]@{name = "SalesContract"   ; version = '20.0.10.5' },
        [pscustomobject]@{name = "Payment"         ; version = '20.0.10.5' },
        [pscustomobject]@{name = "DataMigration"   ; version = '20.0.10.9' },
        [pscustomobject]@{name = "PersonalVoucher" ; version = '20.0.10.1' },
        [pscustomobject]@{name = "Commission"      ; version = '20.0.10.0' },
        [pscustomobject]@{name = "GDPR"            ; version = '20.0.10.0' },
        [pscustomobject]@{name = "ImportPurchase"  ; version = '20.0.10.0' },
        [pscustomobject]@{name = "Sample"          ; version = '20.0.10.0' },
        [pscustomobject]@{name = "Service"         ; version = '20.0.10.0' },
        [pscustomobject]@{name = "HoldingReport"   ; version = '20.0.10.0' },
        [pscustomobject]@{name = "ITIntegration"   ; version = '20.0.10.0' },
        [pscustomobject]@{name = "SIIntegration"   ; version = '20.0.10.0' },
        [pscustomobject]@{name = "MKIntegration"   ; version = '20.0.10.3' },
        [pscustomobject]@{name = "SandboxJAM"      ; version = '20.0.10.0' }
    )
    return $NavExtension
}
