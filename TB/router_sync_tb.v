module router_sync_tb();
reg clk, resetn, detect_add, full_0, full_1, full_2, empty_0, empty_1, empty_2, write_enb_reg, read_enb_0, read_enb_1, read_enb_2;

reg [1:0]datain;
wire [2:0]write_enb;
wire fifo_full, soft_reset_0, soft_reset_1, soft_reset_2, vld_out_1, vld_out_2, vld_out_0;

router_sync DUT(.clk(clk),
				 .resetn(resetn), 
				 .detect_add(detect_add), 
				 .full_0(full_0), 
				 .full_1(full_1), 
				 .full_2(full_2), 
				 .empty_0(empty_0), 
				 .empty_1(empty_1), 
				 .empty_2(empty_2), 
				 .write_enb_reg(write_enb_reg), 
				 .read_enb_0(read_enb_0), 
				 .read_enb_1(read_enb_1), 
				 .read_enb_2(read_enb_2), 
				 .datain(datain), 
				 .write_enb(write_enb),
				 .fifo_full(fifo_full),
				 .soft_reset_0(soft_reset_0),
				 .soft_reset_1(soft_reset_1),
				 .soft_reset_2(soft_reset_2), 
				 .vld_out_1(vld_out_1),
				 .vld_out_2(vld_out_2),
				 .vld_out_0(vld_out_0) ); 
				 
				 			  
	//clock generation
	initial 
	begin
	clk = 1;
	forever 
	#5 clk=~clk;
	end
	
	
	task reset;
		begin
			resetn=1'b0;
			#10;
			resetn=1'b1;
		end
	endtask
	
task task1();
	begin
		
		detect_add=1'b1;
		datain=2'b10;
		read_enb_0=1'b0;
		read_enb_1=1'b1;
		read_enb_2=1'b0;
		write_enb_reg=1'b1;
		full_0=1'b0;
		full_1=1'b1;
		full_2=1'b1;
		empty_0=1'b1;
		empty_1=1'b0;
		empty_2=1'b0;
	
	end
endtask
	
	initial 
		begin
			reset;
			#5;
			task1();
			#1000;
			$finish;
		end
	endmodule 