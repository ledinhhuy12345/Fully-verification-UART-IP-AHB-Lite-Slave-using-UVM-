package env_pkg;
  import uvm_pkg::*;
  import ahb_pkg::*;
  import uart_pkg::*;
  import uart_regmodel_pkg::*;
	
	`include "uart_coverage.sv"
	`include "uart_scoreboard.sv"
        `include "uart_environment.sv"

endpackage
