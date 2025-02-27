
class agent extends uvm_agent;
  `uvm_component_utils(agent);
  
  apb_config a_cfg;
  uvm_sequencer #(transaction) seqr;
  driver drv;
  monitor mon;
  
  function new(input string path = "agent", uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    a_cfg = apb_config::type_id::create("a_cfg");
    mon = monitor::type_id::create("mon",this);
    
    if (a_cfg.is_active == UVM_ACTIVE) begin
        drv = driver::type_id::create("drv",this);
        seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
      end
      
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (a_cfg.is_active == UVM_ACTIVE)
		begin
       drv.seq_item_port.connect(seqr.seq_item_export);
        end
  endfunction
  
endclass: agent