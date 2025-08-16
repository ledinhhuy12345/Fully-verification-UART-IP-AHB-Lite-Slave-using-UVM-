class uart_monitor extends uvm_monitor;
`uvm_component_utils(uart_monitor);
virtual uart_if uart_vif;
uart_config cfg;
uart_transaction s_trans,r_trans;
real bit_time;
uvm_analysis_port #(uart_transaction) item_observed_port;

function new(string name="uart_monitor", uvm_component parent);
   super.new(name, parent);
    item_observed_port=new("item_observed_port", this);
 
endfunction: new

virtual function void build_phase (uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(virtual uart_if)::get(this,"","uart_vif",uart_vif))
			`uvm_fatal(get_type_name(), $sformatf("Fail to get uart_if"));
	if(!uvm_config_db #(uart_config)::get(this,"","cfg",cfg))
      `uvm_fatal(get_type_name(), $sformatf("Fail to get uart_config"));
endfunction: build_phase


virtual task run_phase(uvm_phase phase);

					if(cfg.mode==uart_config::FULL)
						fork
							tx_capture();
							rx_capture();
						join
			else begin
						fork
							tx_capture();
              rx_capture();
						join_any

				end
endtask: run_phase
task tx_capture();
		forever begin
		s_trans=uart_transaction::type_id::create("s_trans", this);
		wait (uart_vif.tx==0);
		bit_time=((1.0e9/cfg.baud_rate));
		#(bit_time*0.5*1ns);
		s_trans.direction = 1'b0;
		for (int i=0; i<cfg.data_width; i++) begin
				 #((bit_time)*1ns);
				s_trans.data[i]=uart_vif.tx;
			
		end
		`uvm_info("[UART_MONITOR]",$sformatf("DATA TX CAPTURE: data = 0'%0h", s_trans.data), UVM_LOW)
		
		if(!(cfg.parity_type== uart_config::NONE||cfg.data_width == 9)) begin
				#((bit_time)*1ns);
				s_trans.parity=uart_vif.tx;
				`uvm_info(get_type_name(), $sformatf("TX Capture: capture parity= %0b", s_trans.parity), UVM_HIGH)
		end
		for (int i=0; i<cfg.stop_width; i++) begin
				#((bit_time)*1ns);
				s_trans.stop[i]=uart_vif.tx;
		end
		item_observed_port.write(s_trans);
	end
endtask: tx_capture
task rx_capture();
	
	
			bit  soluongbit1;
			bit  expected_parity;
		forever begin
		r_trans=uart_transaction::type_id::create("r_trans", this);
		wait (uart_vif.rx==0);
		bit_time=((1.0e9/cfg.baud_rate));
      #((bit_time)*0.5*1ns);
      r_trans.direction = 1'b1;
      for (int j=0; j<cfg.data_width; j++) begin
          #((bit_time)*1ns);
         r_trans.data[j]=uart_vif.rx;
      end
			`uvm_info(get_type_name(), $sformatf("trans.data= 0x0%h", r_trans.data), UVM_LOW)

      if(!(cfg.parity_type== uart_config::NONE||cfg.data_width == 9)) begin
          #((bit_time)*1ns);
          r_trans.parity=uart_vif.rx;
					`uvm_info(get_type_name(), $sformatf("RX Capture: capture parity= %0b", r_trans.parity), UVM_HIGH)
      end
      for (int j=0; j<cfg.stop_width; j++) begin
          #((bit_time)*1ns);
          r_trans.stop[j]=uart_vif.rx;
      end

			soluongbit1 = ^(r_trans.data);
			if(cfg.parity_type == uart_config::EVEN) expected_parity=  soluongbit1;
      if(cfg.parity_type == uart_config::ODD) expected_parity=  ~soluongbit1;
			if(cfg.parity_type == uart_config::NONE) expected_parity=  1'bx; 
      


			if(cfg.parity_type != uart_config::NONE) begin

					if(r_trans.parity !== expected_parity) begin
						`uvm_error("UART MONITOR", $sformatf("[PARITY ERROR] Data: 0x%0h | expected parity: %0b | actual parity: %0b", r_trans.data, expected_parity, r_trans.parity))
					end else begin
						`uvm_info("UART MONITOR", $sformatf("[PARITY PASS] Data: 0x%0h | expected parity: %0b | actual parity: %0b", r_trans.data, expected_parity, r_trans.parity), UVM_LOW)

					end
				end
			item_observed_port.write(r_trans);
			`uvm_info(get_type_name(), $sformatf("trans.data= 0x0%h", r_trans.data), UVM_LOW)
	end
  endtask: rx_capture
endclass: uart_monitor
