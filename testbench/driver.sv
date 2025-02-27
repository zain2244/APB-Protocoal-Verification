class driver extends uvm_driver #(transaction);
  
  `uvm_component_utils(driver);
  
  virtual apb_if aif;
  transaction tr;
  
  function new(string path = "driver", uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual  function void build_phase(uvm_phase phase);
  
    super.build_phase(phase);
    tr = transaction :: type_id :: create("tr");
    if (!uvm_config_db #(virtual apb_if)::get(this,"","aif",aif))
      `uvm_error("DRV", "unable to access interface");
    
  endfunction
  
  task reset_dut();
    repeat(5) begin
      
      aif.presetn <= 1'b0;
      aif.psel <= 1'b0;
      aif.penable <= 1'b0;
      aif.pwrite <= 1'b0;
      aif.paddr <= 'h0;
      aif.pwdata <= 'h0;
      aif.prdata <= 'h0;
      `uvm_info("DRV", "Reset apply to Simulation",UVM_MEDIUM);
      
    end
  endtask
  
  task drive();
    reset_dut();
    forever begin
      
      seq_item_port.get_next_item(tr);
      
      if (tr.op == reset ) 
	begin
      
  	  aif.presetn <= 1'b0;
      aif.psel <= 1'b0;
      aif.penable <= 1'b0;
      aif.pwrite <= 1'b0;
      aif.paddr <= 'h0;
      aif.pwdata <= 'h0;
      aif.prdata <= 'h0;
      @(posedge aif.pclk);
      
    end
      
      else if (tr.op == writed)
        begin
       aif.presetn <= 1'b1;
      aif.psel <= 1'b1;
      aif.pwrite <= 1'b1;
      aif.paddr <= tr.PADDR;
      aif.pwdata <= tr.PWDATA;
      aif.prdata <= tr.PRDATA;
      @(posedge aif.pclk)
      aif.penable <= 1'b1;
          `uvm_info("DRV",$sformatf("mode is %s, addr is %0d,Read_data is %0d, Write_data is %0d and SLVERR is %0d", tr.op.name(),tr.PADDR, tr.PRDATA, tr.PWDATA, tr.PSLVERR), UVM_NONE);
          @(negedge aif.pready)
          aif.penable <= 1'b0;
          tr.PSLVERR = aif.pslverr;
        end
      
      else if (tr.op == readd)
        begin
          aif.presetn <= 1'b1;
          aif.psel <= 1'b1;
          aif.pwrite <= 1'b0;
          aif.paddr <= tr.PADDR;
          aif.pwdata <= tr.PWDATA;
          aif.prdata <= tr.PRDATA;
          @(posedge aif.pclk)
          aif.penable <= 1'b1;
           `uvm_info("DRV",$sformatf("mode is %s, addr is %0d,Read_data is %0d, Write_data is %0d and SLVERR is %0d", tr.op.name(), tr.PADDR, tr.PWDATA, tr.PRDATA, tr.PSLVERR), UVM_NONE);
          
          @ (negedge aif.pready)
          aif.penable <= 1'b0;
          tr.PRDATA = aif.prdata;
          tr.PSLVERR = aif.pslverr;
        end
      seq_item_port.item_done();
    end
  endtask
  
  virtual task run_phase(uvm_phase phase);
    drive();
  endtask
  
endclass: driver