class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  `uvm_analysis_imp_decl(_ahb)
  `uvm_analysis_imp_decl(_uart)
  uvm_analysis_imp_ahb #(ahb_transaction, uart_scoreboard) ahb_port;
  uvm_analysis_imp_uart #(uart_transaction, uart_scoreboard) uart_port;

  byte ahb_tbr_data[$];
  byte uart_tx_data[$];
  byte uart_rx_data[$];
  byte ahb_rbr_data[$];
 	byte abc; 
 `include "uart_coverage.sv"

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ahb_port = new("ahb_port", this);
    uart_port = new("uart_port", this);
  endfunction

  function void write_ahb(ahb_transaction ahb_trans);
    if (ahb_trans.xact_type == ahb_transaction::WRITE && ahb_trans.addr == `UVM_REG_ADDR_WIDTH'h018) begin
      ahb_tbr_data.push_back(ahb_trans.data[7:0]);
      `uvm_info("SCOREBOARD", $sformatf("AHB WRITE to TBR: data=0x%0h", ahb_trans.data[7:0]), UVM_LOW)
    end
    else if (ahb_trans.xact_type == ahb_transaction::READ && ahb_trans.addr == `UVM_REG_ADDR_WIDTH'h01C) begin
      ahb_rbr_data.push_back(ahb_trans.data[7:0]);
      `uvm_info("SCOREBOARD", $sformatf("AHB READ from RBR: data=0x%0h", ahb_trans.data[7:0]), UVM_LOW)
    end
  endfunction

  function void write_uart(uart_transaction uart_trans);
    if (uart_trans.direction == 1'b0) begin
      uart_tx_data.push_back(uart_trans.data);
     `uvm_info("uart_scoreboard", $sformatf("Received transaction: \n%s", uart_trans.sprint()), UVM_LOW)
    end
    else if (uart_trans.direction == 1'b1) begin
      uart_rx_data.push_back(uart_trans.data);
      `uvm_info("SCOREBOARD", $sformatf("UART RX data: 0x%0h", uart_trans.data), UVM_LOW)
    end
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      wait (ahb_tbr_data.size() > 0 && uart_rx_data.size() > 0 || uart_tx_data.size() > 0 && ahb_rbr_data.size() > 0);
      if (ahb_tbr_data.size() > 0 && uart_rx_data.size() > 0)
				begin
        compare_tx_data();
				end
      else if (ahb_rbr_data.size() > 0 && uart_tx_data.size() > 0)
				begin
        compare_rx_data();
    end
		end
  endtask

  function void compare_tx_data();
    byte expected_data = ahb_tbr_data.pop_front();
    byte actual_data = uart_rx_data.pop_front();
    if (expected_data != actual_data) begin
      `uvm_error("SCOREBOARD", $sformatf("TX data mismatch: expected=0x%0h, actual=0x%0h", expected_data, actual_data))
    end
    else begin
      `uvm_info("SCOREBOARD", $sformatf("TX data match: 0x%0h", actual_data), UVM_LOW)
    end
  endfunction

  function void compare_rx_data();
    byte expected_data = uart_tx_data.pop_front();
    byte actual_data = ahb_rbr_data.pop_front();
		abc= expected_data;
    if (expected_data != actual_data) begin
      `uvm_error("SCOREBOARD", $sformatf("RX data mismatch: expected=0x%0h, actual=0x%0h", expected_data, actual_data))
    end
    else begin
      `uvm_info("SCOREBOARD", $sformatf("RX data match: 0x%0h", actual_data), UVM_LOW)
    end
  endfunction
endclass
