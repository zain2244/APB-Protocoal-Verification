class monitor extends uvm_monitor ;
  `uvm_component_utils(monitor);
  
  uvm_analysis_port #(transaction) send;
  virtual apb_if aif;
  transaction tr;
  
  function new (input string path= "monitor", uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send",this);
    
    tr = transaction::type_id::create("tr",this);
    if (!uvm_config_db #(virtual apb_if) :: get(this,"","aif",aif))
      `uvm_error("MON","unable to access interface");
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      @(posedge aif.pclk)
      if (!aif.presetn) 
        begin
        tr.op = reset;
      `uvm_info("MON","System reset detected",UVM_NONE);
      send.write(tr);
        end
      
      else if (aif.presetn && aif.pwrite)
        begin
        @(negedge aif.pready)
        tr.op = writed;
        tr.PWDATA = aif.pwdata;
      	tr.PADDR = aif.paddr;
      	tr.PSLVERR = aif.pslverr;
          `uvm_info("MON",$sformatf("Mode is %s, Data write is %0d, Addr is %d and SLVERR is %0d",tr.op.name(),aif.pwdata,aif.paddr,aif.pslverr),UVM_NONE);
      send.write(tr);
        end
    
      else if (aif.presetn && !aif.pwrite)
        begin
        @(negedge aif.pready)
        tr.op = readd;
      	tr.PRDATA = aif.prdata;
      	tr.PADDR = aif.paddr;
        tr.PSLVERR = aif.pslverr;
          `uvm_info("MON",$sformatf("Mode is %s, Data Read is %0d, Addr is %d and SLVERR is %0d",tr.op.name(),aif.prdata,aif.paddr,aif.pslverr),UVM_NONE);
      send.write(tr);
    end
    
    end
  endtask
  
endclass: monitor
