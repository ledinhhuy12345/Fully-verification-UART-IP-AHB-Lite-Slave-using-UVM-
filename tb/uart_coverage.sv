class uart_coverage extends uvm_component;
  `uvm_component_utils(uart_coverage)

  uvm_analysis_imp#(ahb_transaction, uart_coverage) analysis_export;
  covergroup ahb_cg with function sample(ahb_transaction ahb_trans);
    option.per_instance = 1;

    cp_xact_type: coverpoint ahb_trans.xact_type {
      bins READ = {ahb_transaction::READ};
      bins WRITE = {ahb_transaction::WRITE};
    }

    cp_addr: coverpoint ahb_trans.addr {
      bins MDR = {10'h00};
      bins DLL = {10'h04};
      bins DLH = {10'h08};
      bins LCR = {10'h0C};
      bins IER = {10'h10};
      bins FSR = {10'h14};
      bins TBR = {10'h18};
      bins RBR = {10'h1C};
      bins reserved = {10'h020};
    }

    cp_data: coverpoint ahb_trans.data[7:0] {
      bins zero = {8'h00};
      bins max = {8'hFF};
      bins other[] = {[8'h01:8'hFE]};
			ignore_bins other_14_15 = {14,15,17,18,21,24,26,[28:30], 34,36,37,39,65,68,70,71,72,75,76,78,80,82,83, [86:92], [94:99], 101,102,103, 105,106, 108, [110:120], [122:127], 129,130, 132, [134:137], [140:144], [146:157], [159:162], [164:188], [190:199], [201:221], [223:246], [249:254]};
    }

    cross_xact_addr: cross cp_xact_type, cp_addr {
      bins read_valid = binsof(cp_xact_type.READ) && (binsof(cp_addr.MDR) || 
                                                      binsof(cp_addr.DLL) ||
                                                      binsof(cp_addr.DLH) ||
                                                      binsof(cp_addr.LCR) ||
                                                      binsof(cp_addr.IER) ||
                                                      binsof(cp_addr.FSR) ||
                                                      binsof(cp_addr.RBR));
      bins write_valid = binsof(cp_xact_type.WRITE) && (binsof(cp_addr.MDR) ||
                                                       binsof(cp_addr.DLL) ||
                                                       binsof(cp_addr.DLH) ||
                                                       binsof(cp_addr.LCR) ||
                                                       binsof(cp_addr.IER) ||
                                                       binsof(cp_addr.TBR));
      ignore_bins read_tbr = binsof(cp_xact_type.READ) && binsof(cp_addr.TBR);
      ignore_bins write_rbr = binsof(cp_xact_type.WRITE) && binsof(cp_addr.RBR);

      bins read_reserved = binsof(cp_xact_type.READ) && binsof(cp_addr.reserved);
      bins write_reserved = binsof(cp_xact_type.WRITE) && binsof(cp_addr.reserved);
    }
  endgroup
    
    function new(string name = "uart_coverage", uvm_component parent);
      super.new(name, parent);
      analysis_export = new("analysis_export", this);
      ahb_cg = new();
    endfunction

    virtual function void write(ahb_transaction trans);
      ahb_cg.sample(trans);
    endfunction

endclass
