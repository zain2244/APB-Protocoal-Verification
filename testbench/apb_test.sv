
`include "package.sv"

class apb_test extends uvm_test;
  
  env e;
  
  `uvm_component_utils(apb_test);
  
  read_data rd;
  write_data wd;
  write_read wr;
  writeb_readb wbrb;
  write_err  we;
  read_err re;
  reset_data red;
  
  function new(input string path="apb_test", uvm_component parent);
    
    super.new(path,parent);
    
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e = env::type_id::create("e",this);
    rd = read_data::type_id::create("rd");
    wd = write_data::type_id::create("wd");
    wr = write_read::type_id::create("wr");
    wbrb = writeb_readb::type_id::create("wbrb");
    we = write_err::type_id::create("we");
    re = read_err :: type_id::create("re");
    red = reset_data::type_id::create("red");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
  
    phase.raise_objection(this);
    we.start(e.a.seqr);
    re.start(e.a.seqr);
    red.start(e.a.seqr);
    wr.start(e.a.seqr);
    rd.start(e.a.seqr);
    wd.start(e.a.seqr);
    wbrb.start(e.a.seqr);
    #20;
    phase.drop_objection(this);
    
  endtask
endclass: apb_test
