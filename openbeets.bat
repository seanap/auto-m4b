# Download and install PuTTY before running this script!
#
# For optimal experiance using cmd.exe in Windows10:
# Open powershell as administrator, run the following command:
# Set-ItemProperty HKCU:\Console VirtualTerminalLevel -Type DWORD 1
#
# Modify the below command with your USERNAME, IP, PASSWORD of the linux computer that is running the beets docker.
# To run just double click this .bat file from your windows pc
#
plink -ssh username@192.168.0.123 -pw supersecretpass -P 22 -t (docker exec -it beets sh -c 'beet import /untagged')
