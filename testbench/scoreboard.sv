
class sco extends uvm_scoreboard;
  `uvm_component_utils(sco);
  
  transaction tr;
  uvm_analysis_imp #(transaction,sco) recv;
  
  bit [31:0] array [32] = '{default:0};
  bit [31:0] data_read = 0;
  bit [31:0] addr= 0;
  function new(input string path = "sco", uvm_component parent);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    recv = new("recv",this);
    
  endfunction
  
  virtual function void write(transaction tr);
    
    if (tr.op == reset) begin
      `uvm_info("Sco", "System_reset detected",UVM_NONE);
    end 
      else if (tr.op == writed)
		 begin
           if (tr.PSLVERR == 1'b1) 
             begin 
               `uvm_info("Sco","Write Data Error detected",UVM_NONE);
             end
        	else 
				begin
                  array[tr.PADDR] = tr.PWDATA;
          `uvm_info("Sco",$sformatf("Data write op is %0d, addr is %0d, array is %0d",tr.PWDATA,tr.PADDR,array[tr.PADDR]),UVM_NONE);
         end
         end
    
    else if (tr.op == readd)
      begin
        if (tr.PSLVERR == 1'b1)
          begin
            `uvm_info("Sco","Read Data Error detected",UVM_NONE);    			end
        else begin
          data_read = array[tr.PADDR];
          `uvm_info("Sco",$sformatf("Data Read op is %0d, addr is %0d, array is %0d",data_read,tr.PADDR,array[tr.PADDR]),UVM_NONE);
        end
      end
    $display("--------------------------------------");
  endfunction
  
endclass : sco
