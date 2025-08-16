package seq_pkg;
  import uvm_pkg::*;
  import ahb_pkg::*;
  import uart_pkg::*;

  `include "uart_sequence.sv"
  `include "ahb_write_reserved_sequence.sv"
  `include "ahb_read_reserved_sequence.sv"
endpackage
