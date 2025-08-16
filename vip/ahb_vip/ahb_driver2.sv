class ahb_driver extends uvm_driver #(ahb_transaction);
  `uvm_component_utils(ahb_driver)
	
  virtual ahb_if ahb_vif;
  bit [`AHB_ADDR_WIDTH-1:0] rdata;

  function new(string name="ahb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    /** Applying the virtual interface received through the config db - learn detail in next session*/
    if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get from uvm_config_db. Please check!"))
  endfunction: build_phase

  /** User can use ahb_vif to control real interface like systemverilog part*/
  virtual task run_phase(uvm_phase phase);

	`uvm_info("Run_phase", "ENTERED......", UVM_HIGH)
	forever begin	
		seq_item_port.get(req);
		`uvm_info(get_full_name(), $sformatf("Check AHB_bus: \n %s", req.sprint()), UVM_HIGH)
		if(req.xact_type == ahb_transaction::WRITE) begin
			wait(ahb_vif.HRESETn==1);
			
			@(posedge ahb_vif.HCLK);#1ns;
			ahb_vif.HADDR     = req.addr;
			ahb_vif.HBURST    = req.burst_type;
			ahb_vif.HMASTLOCK = req.lock;
			ahb_vif.HPROT     = req.prot;
			ahb_vif.HSIZE     = req.xfer_size;
			ahb_vif.HTRANS    = 2'b10;
        		ahb_vif.HWRITE    = req.xact_type;
			
			@(posedge ahb_vif.HCLK);#1ns;
			ahb_vif.HADDR     = 0;
			ahb_vif.HBURST    = 0;
			ahb_vif.HMASTLOCK = 0;
			ahb_vif.HPROT     = 0;
			ahb_vif.HSIZE     = 0;
			ahb_vif.HTRANS    = 0;
        		ahb_vif.HWDATA    = req.data;
			`uvm_info("[ahb_driver]", $sformatf("Check HWDATA data = 'h%0h", req.data), UVM_LOW)
			ahb_vif.HWRITE    = 0;
			
			wait(ahb_vif.HREADYOUT == 1);
			
		end else
		if(req.xact_type == ahb_transaction::READ) begin
			wait(ahb_vif.HRESETn==1);
			
			@(posedge ahb_vif.HCLK);#1ns;
			ahb_vif.HADDR     = req.addr;
			ahb_vif.HBURST    = req.burst_type;
			ahb_vif.HMASTLOCK = req.lock;
			ahb_vif.HPROT     = req.prot;
			ahb_vif.HSIZE     = req.xfer_size;
			ahb_vif.HTRANS    = 2'b10;
        		ahb_vif.HWRITE    = req.xact_type;
		
			@(posedge ahb_vif.HCLK);#1ns;
			ahb_vif.HADDR     = 0;
			ahb_vif.HBURST    = 0;
			ahb_vif.HMASTLOCK = 0;
			ahb_vif.HPROT     = 0;
			ahb_vif.HSIZE     = 0;
			ahb_vif.HTRANS    = 0;

			wait(ahb_vif.HREADYOUT == 1);
			@(posedge ahb_vif.HCLK);
			rdata = ahb_vif.HRDATA;
			`uvm_info("[ahb_driver]", $sformatf("Check HRDATA data = 'h%0h", req.data), UVM_LOW)
		end
		
		$cast(rsp,req.clone());
		if(rsp.xact_type == ahb_transaction::READ) begin
		rsp.data = rdata;
		`uvm_info("[ahb_driver]", $sformatf("Check rsp HRDATA data = 'h%0h", rsp.data), UVM_LOW)
		end
		rsp.set_id_info(req);
		seq_item_port.put(rsp);
	end
	
		`uvm_info("Run_phase", "EXITED......", UVM_HIGH)

  endtask: run_phase

endclass: ahb_driver

