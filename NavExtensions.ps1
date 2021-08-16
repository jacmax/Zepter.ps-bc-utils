function GetNavExtensions {
    $NavExtension =
        @(
            [pscustomobject]@{name="BaseAppOld"      ;version= '18.0.23013.23798'},
            [pscustomobject]@{name="BaseApp"         ;version= '18.0.23013.23799'},
            [pscustomobject]@{name="Common"          ;version= '0.1.0.6'},
            [pscustomobject]@{name="SalesItem"       ;version= '0.1.0.3'},
            [pscustomobject]@{name="Representative"  ;version= '0.1.0.3'},
            [pscustomobject]@{name="SalesContract"   ;version= '0.1.0.6'},
            [pscustomobject]@{name="Payment"         ;version= '0.1.0.5'},
            [pscustomobject]@{name="PersonalVoucher" ;version= '0.1.0.2'},
            [pscustomobject]@{name="Commission"      ;version= '0.1.0.7'},
            [pscustomobject]@{name="GDPR"            ;version= '0.1.0.1'},
            [pscustomobject]@{name="ImportPurchase"  ;version= '0.1.0.1'},
            [pscustomobject]@{name="Sample"          ;version= '0.1.0.1'},
            [pscustomobject]@{name="Service"         ;version= '0.1.0.3'},
            [pscustomobject]@{name="HoldingReport"   ;version= '0.1.0.0'},
            [pscustomobject]@{name="ITIntegration"   ;version= '0.1.0.2'}
        )
    return $NavExtension
}
