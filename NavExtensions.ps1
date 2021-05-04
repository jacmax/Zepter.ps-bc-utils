function GetNavExtensions {
    $NavExtension =
        @(
            [pscustomobject]@{name="BaseAppOld"      ;version= '18.0.23013.23795'},
            [pscustomobject]@{name="BaseApp"         ;version= '18.0.23013.23796'},
            [pscustomobject]@{name="Common"          ;version= '0.1.0.1'},
            [pscustomobject]@{name="SalesItem"       ;version= '0.1.0.1'},
            [pscustomobject]@{name="Representative"  ;version= '0.1.0.0'},
            [pscustomobject]@{name="SalesContract"   ;version= '0.1.0.1'},
            [pscustomobject]@{name="Payment"         ;version= '0.1.0.1'},
            [pscustomobject]@{name="PersonalVoucher" ;version= '0.1.0.1'},
            [pscustomobject]@{name="Commission"      ;version= '0.1.0.4'},
            [pscustomobject]@{name="GDPR"            ;version= '0.1.0.1'},
            [pscustomobject]@{name="ImportPurchase"  ;version= '0.1.0.1'},
            [pscustomobject]@{name="Sample"          ;version= '0.1.0.0'},
            [pscustomobject]@{name="Service"         ;version= '0.1.0.3'},
            [pscustomobject]@{name="ITIntegration"   ;version= '0.1.0.0'}
        )
    return $NavExtension
}
