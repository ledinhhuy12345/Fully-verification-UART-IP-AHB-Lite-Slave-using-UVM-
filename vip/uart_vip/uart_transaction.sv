class uart_transaction extends uvm_sequence_item;
	rand bit [7:0] data;
	bit parity;
	bit [1:0] stop;
	rand bit direction;
`uvm_object_utils_begin (uart_transaction)
		`uvm_field_int (data,   UVM_ALL_ON | UVM_BIN)
		`uvm_field_int (parity, UVM_ALL_ON | UVM_BIN)
		`uvm_field_int (stop,   UVM_ALL_ON | UVM_BIN)
		`uvm_field_int (direction, UVM_ALL_ON)
`uvm_object_utils_end
function new(string name="uart_transaction");
		super.new(name);
		parity= 2'bxx;
endfunction: new
endclass: uart_transaction
