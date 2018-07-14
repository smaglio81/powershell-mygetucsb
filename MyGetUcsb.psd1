@{
RootModule = 'MyGetUcsb.psm1'
ModuleVersion = '0.5'
GUID = '1d73a601-4a6c-43c5-ba3f-619b18bbb404' # Use [GUID]::NewGuid()
Author = 'maglio-s, michael simmons, ADMS'
Description = 'MyGetUcsb to use when developing new modules'
CompanyName = 'Student Affairs, UCSB'
Copyright = '(c) 2014 Student Affairs, UCSB'
PowerShellVersion = '3.0'
FormatsToProcess = 'MyGetUcsb.Format.ps1xml'
#NestedModules = @('SourceTypes\PSGallery\PSGallery.psm1')
# Functions, variables, and aliases are all redundant with the Export-ModuleMember
# It's important to define these types when importing methods from a C# dll, but when using a .psm1
# it's probably easier to define them at the bottom of the .psm1 file. And example is provided in
# MyGetUcsb.psm1
#FunctionsToExport = 'Verb-SAFunction1'
#VariablesToExport = "*"
#AliasesToExport = 'vsaf1'
FileList = 'MyGetUcsb.psm1', 'MyGetUcsb.Format.ps1xml'
#HelpInfoURI = 'http://go.microsoft.com/fwlink/?LinkId=393271'
}
