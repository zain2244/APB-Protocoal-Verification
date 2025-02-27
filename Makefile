# Makefile
TEST 		= 
TIME_OUT	= 9200000
rtl_dir = rtl
tb_dir = testbench

# to compile the code on vcs, run `make compile` command in the terminal
compile:
	vcs -ntb_opts uvm-1.2 +incdir+$(rtl_dir)  +incdir+$(tb_dir) -sverilog $(rtl_dir)/design.sv  $(tb_dir)/testbench.sv -cm line+cond+tgl+fsm   -full64 -debug_all
# for simulation, run `make sim` command in the terminal
sim: 
	./simv -cm line+cond+tgl+assert +UVM_TESTNAME=$(TEST)
# To view waveform, run `make gui` command in the terminal
gui: 
	./simv -gui/ &	

# More advance make targets
cov:
	urg -report  coverage_report -dir  *.vdb

allclean:
	clear 
	rm -rf csrc *.daidir urgReport coverage_report simv func_report tr_db.log ucli.key vc_hdrs.h *.vdb DVEfiles urgReport *_test *.txt *.log
clean: 
	rm -rf csrc DVEfiles inter.vpd simv simv.daidir simv.vdb tr_db.log ucli.key vc_hdrs.h novas.conf novas_dump.log *.txt *.vdb *.daidir test *.cst *.log 

all:
	make build

dve_cov:
	dve -covdir simv.vdb

