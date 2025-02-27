// Code your testbench here

interface apb_if #(parameter int INPUT_WIDTH = 6, parameter int OUTPUT_WIDTH = 32);
  
  logic presetn;
  logic pclk;
  logic psel;
  logic penable;
  logic pwrite;
  logic [31:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic pready;
  logic pslverr;
  
   // Covergroup for monitoring signals
  // Covergroup for monitoring signals
  covergroup apb_covergroup @(posedge pclk);
    
    // Coverpoint for `paddr` signal (input width)
    coverpoint paddr {
      bins low_values  = {[0:15]};          // Covers small values
      bins mid_values  = {[16:31]};         // Covers mid-range values
      bins high_values = {[32:INPUT_WIDTH-1]}; // Covers high values
    }
    
    // Coverpoint for `pwdata` signal (output width)
    coverpoint pwdata {
      bins lower_quarter = {[0:OUTPUT_WIDTH/4]};       // Covers 0 to 1/4 of max
      bins mid_range     = {[OUTPUT_WIDTH/4:3*OUTPUT_WIDTH/4]}; // Covers mid-range
      bins upper_quarter = {[3*OUTPUT_WIDTH/4:OUTPUT_WIDTH-1]}; // Covers 3/4 to max
    }

     // Coverpoint for `prdata` signal (output width)
    coverpoint prdata {
      bins lower_quarter = {[0:OUTPUT_WIDTH/4]};       // Covers 0 to 1/4 of max
      bins mid_range     = {[OUTPUT_WIDTH/4:3*OUTPUT_WIDTH/4]}; // Covers mid-range
      bins upper_quarter = {[3*OUTPUT_WIDTH/4:OUTPUT_WIDTH-1]}; // Covers 3/4 to max
    }

    // Coverpoint for `overflow` signal
    coverpoint psel {
      bins no_sel = {1'b0}; // Overflow not set
      bins sel  = {1'b1}; 
      // Overflow set
    }

     coverpoint penable {
      bins no_enable = {1'b0}; // Overflow not set
      bins enable  = {1'b1}; // Overflow set
    }

    coverpoint pready {
      bins no_ready = {1'b0}; // Overflow not set
      bins ready  = {1'b1}; // Overflow set
    }
    
      coverpoint pwrite {
      bins no_write = {1'b0}; // Overflow not set
      bins write  = {1'b1}; // Overflow set
    }

    coverpoint pslverr {
      bins no_error = {1'b0}; // Overflow not set
      bins error  = {1'b1}; // Overflow set
    }


    // Cross coverage for `n` and `overflow`
    cross pready, penable,pslverr;
    
  endgroup


  //Covergroup instantiation
  initial begin
    apb_covergroup cg = new();
  end

endinterface

`include "apb_test.sv"

`include "uvm_macros.svh"
 import uvm_pkg::*;
 

///typedef enum bit [1:0] {readd = 0, writed = 1, reset = 2} oper_mode;

module tb();
  
  apb_if aif();
  
  apb_ram dut( 
    		 	.presetn(aif.presetn),
                .pclk(aif.pclk),
            	.psel(aif.psel),
                .penable(aif.penable),
            	.pwrite(aif.pwrite),
            	.paddr(aif.paddr),
            	.pwdata(aif.pwdata),
            	.prdata(aif.prdata),
            	.pready(aif.pready),
            	.pslverr(aif.pslverr)  
  );
     
    initial begin
      aif.pclk = 0;
      aif.presetn = 0;
    end
  
  always #10 aif.pclk = ~aif.pclk;
  
  initial begin
    uvm_config_db #(virtual apb_if) :: set(null,"*","aif",aif);
    run_test("");
    
  end
  
endmodule
