module router_fifo_tb();
//parameter DELAY=10;
//parameter DEPTH=16, WIDTH=9, ADD_SIZE=5;
reg clk, resetn, write_enb, read_enb, lfd_state, soft_reset;
reg [7:0]data_in;
wire full, empty;	
wire [7:0]data_out;


router_fifo DUT    (.clk(clk),
					.resetn(resetn),
					.soft_reset(soft_reset),
					.write_enb(write_enb),
					.read_enb(read_enb),
					.lfd_state(lfd_state),
					.datain(data_in),
					.full(full),
					.empty(empty),
					.dataout(data_out));

	//clock generation
	initial begin
	clk = 1;
	forever 
	#5 clk=~clk;
	end
	


initial 
	begin
	resetn=1'b0;
	#10;
	resetn=1'b1;
	soft_reset=1'b0;
	lfd_state=1'b1;
	write_enb=1'b1;
	#10;
	repeat(17)
		begin
			data_in=$random;
			#10;
		end
	write_enb=1'b0;
	#5;
	
	read_enb=1'b1;
	#100;
	
 
	$finish; 
	end 
endmodule
