typedef enum bit [1:0] {readd = 0, writed = 1, reset = 2} oper_mode;


class transaction extends uvm_sequence_item;
    
///typedef enum bit [1:0] {readd = 0, writed = 1, reset = 2} oper_mode;


  rand oper_mode op;
  ///input signal///
  rand logic PWRITE;
  rand logic [31:0] PADDR;
  rand logic [31:0] PWDATA;
  ///output signall///
  logic [31:0] PRDATA;
  logic PREADY,PSLVERR;
  
  `uvm_object_utils_begin(transaction);
  `uvm_field_int(PWRITE, UVM_ALL_ON);
  `uvm_field_int(PADDR, UVM_ALL_ON);
  `uvm_field_int(PWDATA, UVM_ALL_ON);
  `uvm_field_int(PRDATA, UVM_ALL_ON);
  `uvm_field_int(PREADY, UVM_ALL_ON);
  `uvm_field_int(PSLVERR, UVM_ALL_ON);
  `uvm_field_enum(oper_mode, op, UVM_DEFAULT);
  `uvm_object_utils_end
  
  constraint addr_c { PADDR <=31 ; }
  constraint addr_c_err { PADDR > 31 ; }
  
  function new(string path = "transaction");
    super.new(path);
  endfunction
  
endclass: transaction