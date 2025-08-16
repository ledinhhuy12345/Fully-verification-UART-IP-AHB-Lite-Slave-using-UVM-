class ahb_write_reserved_sequence extends uvm_sequence #(ahb_transaction);
  `uvm_object_utils(ahb_write_reserved_sequence)

  function new(string name="ahb_write_reserved_sequence");
    super.new(name);
  endfunction

  virtual task body();

      req = ahb_transaction::type_id::create("req");
      start_item(req);
      
      
	
      if(req.randomize() with {addr        == 'h020;
                            xact_type   == ahb_transaction::WRITE;
                            burst_type  == ahb_transaction::SINGLE;
                            xfer_size   == ahb_transaction::SIZE_32BIT;})
				begin
					`uvm_info(get_type_name(),$sformatf("Send req to driver: \n %s",req.sprint()),UVM_LOW);
				end else begin 
					`uvm_fatal(get_type_name(), $sformatf("Randomize failed"))
				end
      finish_item(req);
      get_response(rsp);

    `uvm_info(get_type_name(),$sformatf("Recevied rsp to driver: \n %s",rsp.sprint()),UVM_LOW);
  endtask: body

endclass: ahb_write_reserved_sequence
