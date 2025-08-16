class uart_environment extends uvm_env;
  `uvm_component_utils(uart_environment)

  virtual ahb_if  ahb_vif;
	virtual uart_if uart_vif;
  ahb_agent       ahb_agt;
uart_agent      uart_agt;
	uart_config cfg;
	uart_reg_block  regmodel;
	uart_reg2ahb_adapter ahb_adapter;
  // Predictor class creation
  uvm_reg_predictor #(ahb_transaction) ahb_predictor;
	uart_coverage uart_cov;
	uart_scoreboard uart_sb;

  function new(string name="uart_environment", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
		`uvm_info("[UART_ENVIRONMENT]", "BAT DAU build phase", UVM_LOW)
    if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get ahb_vif from uvm_config_db"))
		if(!uvm_config_db#(virtual uart_if)::get(this,"","uart_vif",uart_vif))
        `uvm_fatal(get_type_name(),$sformatf("Failed to get uart_vif from uvm_config_db"))
		if(!uvm_config_db#(uart_config)::get(this,"","cfg",cfg))
          `uvm_fatal("UVM_ENVIRONMENT",$sformatf("Failed to get UART_CONFIG")) 



		uart_agt = uart_agent::type_id::create("uart_agt",this);
    ahb_agt = ahb_agent::type_id::create("ahb_agt",this);

    ahb_predictor = uvm_reg_predictor#(ahb_transaction)::type_id::create("ahb_predictor",this);
		
		regmodel = uart_reg_block::type_id::create("regmodel", this);
		regmodel.build();

		ahb_adapter = uart_reg2ahb_adapter::type_id::create("ahb_adapter");
		if(!uart_cov) begin
		uart_cov = uart_coverage::type_id::create("uart_coverage", this);
		end
		if(!uart_sb) begin
		uart_sb = uart_scoreboard::type_id::create("uart_scoreboard",this);
		end
		uvm_config_db#(virtual uart_if)::set(this,"uart_agt","uart_vif",uart_vif);	
    uvm_config_db#(virtual ahb_if)::set(this,"ahb_agt","ahb_vif",ahb_vif);
		uvm_config_db#(uart_config)::set(this,"uart_sb","cfg",cfg);
		uvm_config_db#(uart_config)::set(this,"uart_agt","cfg",cfg);
		uvm_config_db#(uvm_active_passive_enum)::set(this,"uart_agt","is_active",UVM_ACTIVE);
		`uvm_info("[UART_ENVIRONMENT]", "KET THUC build phase", UVM_LOW)
  endfunction: build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
	  `uvm_info("CONNECT PHASE","BAT DAU",UVM_LOW)
		if(regmodel.get_parent() == null)
				regmodel.ahb_map.set_sequencer(ahb_agt.sequencer, ahb_adapter);    
    // Predictor connection
    ahb_predictor.map = regmodel.ahb_map;
    ahb_predictor.adapter = ahb_adapter;
    ahb_agt.monitor.item_observed_port.connect(ahb_predictor.bus_in);
    
    // Connect monitor to scoreboard
		ahb_agt.monitor.item_observed_port.connect(uart_sb.ahb_port);
		uart_agt.monitor.item_observed_port.connect(uart_sb.uart_port);
		ahb_agt.monitor.item_observed_port.connect(uart_cov.analysis_export);
		`uvm_info("CONNECT PHASE","KET THUC",UVM_LOW)
  endfunction: connect_phase

endclass
