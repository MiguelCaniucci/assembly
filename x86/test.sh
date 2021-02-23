clear

echo 'TESTING...'
echo 

echo '**** Decimal tests ****'
echo
./main '123' ' 321d ' 'hel123lo' 'asse 654 mbly' 'dS13F 42Gt' 
echo '***********************'
echo

echo '***** Binary tests ****'
echo
./main '1011b' 'arch0101110111bitecture' 'vhs 11b 32bit' 'pks110101b'
echo '***********************'
echo

echo '***** Octal tests *****'
echo
./main '352o' 'uni12qversity' 'abc 17o d34h' 'avg246q'
echo '***********************'
echo

echo '** Hexadecimal tests **'
echo
./main '35ach' 'aDGg52h' '14ADFh' 'nBA 3aChFS 13' 
echo '***********************'
echo

echo '***** Other tests *****'
echo
./main 'abcde fgh' ''
echo '***********************'
echo


