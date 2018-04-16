# PlessMON
Security-Framework which emphasizes the 20 Critical Security Controls.
## How to use:
### 1. Download the .psm and either put it in the powershell preferred directory for modules as described [here](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx) or in whatever directory you like.
### 2. Open powershell and type either "import-module PlessMON-Agent.psm1" or "import-module c:\[path-2-downloaded module]\PlessMON-Agent.psm1"
### 3. Type "R" when it asks you whether you trust the publisher of the module.
### 4. Show possible commands by typing "get-command -module PlessMON-Agent.psm1"
# To build a system/host baseline report type "Get-Reports_PMA"
### It will create the html report in the "C:\PlessMON_Agent\Reports" directory with a naming convention of:
### Baseline_ Hostname-Hardware-Date.html,  Hostname-Software-Baseline.html, etc.
### Finally, open the previously built report in your favorite web browser.
