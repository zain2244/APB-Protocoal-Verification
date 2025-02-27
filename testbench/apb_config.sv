class apb_config extends uvm_object;
  `uvm_object_utils(apb_config);
  
  function new(string path="apb_config");
    super.new(path); 
  endfunction
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
endclass: apb_config
