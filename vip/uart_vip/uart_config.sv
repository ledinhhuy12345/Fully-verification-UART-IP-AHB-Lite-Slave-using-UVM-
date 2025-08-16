class uart_config extends uvm_object;
		typedef enum bit [1:0] {
				NONE = 0,
				ODD = 1,
				EVEN = 2
} parity_type_enum;
	typedef enum int{
				TX_RX=1,
				RX_TX=2,
				FULL=3
} mode_enum;
	rand int data_width;
	rand int stop_width;
	rand int baud_rate;
	rand bit is_active;
	rand parity_type_enum parity_type;
	mode_enum mode;
	
	constraint width {
		data_width inside {[5:9]};
		stop_width inside {[1:2]};
		baud_rate inside {2400, 4800, 9600, 19200, 38400, 76800, 115200};
};
	constraint parity{
		if (data_width==9)
				parity_type == NONE;
	};
	constraint data_width_c{
    if (parity_type!=NONE)
        data_width < 9;
    };

		`uvm_object_utils_begin (uart_config)
				`uvm_field_int (data_width, UVM_ALL_ON | UVM_DEC)
				`uvm_field_enum (parity_type_enum, parity_type, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int (stop_width, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int (baud_rate, UVM_ALL_ON | UVM_DEC)
				`uvm_field_enum (mode_enum,mode, UVM_ALL_ON | UVM_BIN)
		`uvm_object_utils_end
function new (string name= "uart_config");
		super.new(name);
endfunction: new
endclass: uart_config
