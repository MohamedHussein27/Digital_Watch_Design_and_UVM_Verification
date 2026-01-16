vlib work
vlog Digital_Watch_FSM.v StopWatch.v Normal_Clock.v Digital_Watch_Top.v Digital_Watch_tb.v  
vsim -voptargs=+acc work.Digital_Watch_tb
do wave.do
run -all