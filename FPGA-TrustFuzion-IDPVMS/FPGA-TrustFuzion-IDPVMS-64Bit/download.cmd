:: ----FPGA TRust Zone Programmer----::
:: NOTE: Make sure FPGA is on and connected. Open a terminal and connect to FPGA with baud rate 9600; 
:: UART Settings: Baud Rate= 9600; Data Bits=8; Stop Bits=1; Parity=None; Handshake =None
:: Start "capture log" before the bit file is programmed
:: 1. Open command prompt from start menu
:: 2. cd to location of the scripts
:: 3. Run "download.cmd" command

@echo off


FOR %%A IN (program1.cmd, program2.cmd, program3.cmd, program4.cmd) DO ( 
START "" /wait /b "C:\Xilinx\14.7\ISE_DS\settings64.bat" impact -batch %%A
PING 1.1.1.1 -n 1 -w 10000 >NUL
echo Programmed %%A bitfile
echo Sending output to UART Terminal DO NOT DISCONNECT CABLE OR FPGA FOR APPRX 5 MINS....
PING 1.1.1.1 -n 1 -w 50000 >NUL
)
echo DONE...! Thats all folks..!