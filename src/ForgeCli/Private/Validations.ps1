class SupportedProvider : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return @($global:ForgeProviders.Keys)
    }
}
