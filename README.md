# digital_systems_project
# these are the commands that you will use in all the exercises
source ~/efp_venv/bin/activate # activate terminal WLS
deactivate	# deactivate WLS
make 	# run simulation 
gtkwave dump.vcd & #open waveform viewer and thanks to the '&' I can use the terminal for more thinks at the same time. Reload the waves in GTKWave using Ctrl+Shift+R

pyfdax to open the filter analyser

NOTES ON EXERCISES:
exercise 2 -> you need to change the file name in MAKEFILE in order to perform the testbench on the terminal
exercise 4 -> need to delete the folders sim_build and _pycache before doing make to be able to execute it without errors


2.2b)
week0802.sv
should be BusExercise.sv