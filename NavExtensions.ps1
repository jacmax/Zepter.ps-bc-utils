function GetNavExtensions {
    $NavExtension =
    @(
        [pscustomobject]@{name = "BaseAppOld"      ; version = '19.0.29894.30693' },
        [pscustomobject]@{name = "BaseApp"         ; version = '19.0.29894.30694' },
        [pscustomobject]@{name = "Common"          ; version = '19.1.0.35' },
        [pscustomobject]@{name = "SalesItem"       ; version = '19.1.0.35' },
        [pscustomobject]@{name = "Representative"  ; version = '19.1.0.35' },
        [pscustomobject]@{name = "SalesContract"   ; version = '19.1.0.35' },
        [pscustomobject]@{name = "Payment"         ; version = '19.1.0.35' },
        [pscustomobject]@{name = "DataMigration"   ; version = '19.1.0.35' },
        [pscustomobject]@{name = "PersonalVoucher" ; version = '19.1.0.35' },
        [pscustomobject]@{name = "Commission"      ; version = '19.1.0.35' },
        [pscustomobject]@{name = "GDPR"            ; version = '19.1.0.35' },
        [pscustomobject]@{name = "ImportPurchase"  ; version = '19.1.0.35' },
        [pscustomobject]@{name = "Sample"          ; version = '19.1.0.35' },
        [pscustomobject]@{name = "Service"         ; version = '19.1.0.35' },
        [pscustomobject]@{name = "HoldingReport"   ; version = '19.1.0.35' },
        [pscustomobject]@{name = "ITIntegration"   ; version = '19.1.0.35' }
    )
    return $NavExtension
}
