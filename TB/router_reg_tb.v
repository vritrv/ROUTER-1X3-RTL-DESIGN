module router_reg_tb();

reg clk, resetn, packet_valid,fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg;
reg [7:0] datain;
wire err, parity_done, low_packet_valid;
wire [7:0]dout;
integer i;
router_reg DUT( .clk(clk),
				.resetn(resetn),
				.packet_valid(packet_valid),
				.fifo_full(fifo_full),
				.detect_add(detect_add),
				.ld_state(ld_state),
				.laf_state(laf_state),
				.full_state(full_state),
				.lfd_state(lfd_state),
				.rst_int_reg(rst_int_reg),
				.datain(datain),
				.err(err),
				.parity_done(parity_done),
				.low_packet_valid(low_packet_valid),
				.dout(dout));   
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
	
	
	task packet1();
	
			reg [7:0]header, payload_data, parity;
			reg [5:0]payloadlen;
			begin
				@(negedge clk);
				payloadlen=8;
				parity=0;
				detect_add=1'b1;
				packet_valid=1'b1;
				header={payloadlen,2'b10};
				datain=header;
				parity=parity^datain;

				@(negedge clk);
				detect_add=1'b0;
				lfd_state=1'b1;
		
				for(i=0;i<payloadlen;i=i+1)	
					begin
					@(negedge clk);	
					lfd_state=0;
					ld_state=1;
	
					payload_data={$random}%256;
					datain=payload_data;
					parity=parity^datain;				
					end

					@(negedge clk);	
					packet_valid=0;
					datain=parity;
				
					@(negedge clk);
					ld_state=0;
					end
		
endtask
task packet2();
	
			reg [7:0]header, payload_data, parity;
			reg [5:0]payloadlen;
			begin
				@(negedge clk);
				payloadlen=8;
				parity=0;
				detect_add=1'b1;
				packet_valid=1'b1;
				header={payloadlen,2'b10};
				datain=header;
				parity=parity^datain;

				@(negedge clk);
				detect_add=1'b0;
				lfd_state=1'b1;
		
				for(i=0;i<payloadlen;i=i+1)	
					begin
					@(negedge clk);	
					lfd_state=0;
					ld_state=1;
	
					payload_data={$random}%256;
					datain=payload_data;
					parity=parity^datain;				
					end

					@(negedge clk);	
					packet_valid=0;
					datain=!parity;
				
					@(negedge clk);
					ld_state=0;
					end
		endtask
initial
	begin
		reset;
		fifo_full=1'b0;
		laf_state=1'b0;
	   full_state=1'b0;
		#20;
		packet1();
		#105;
		packet2();
		$finish;
	end
	
endmodule 
	