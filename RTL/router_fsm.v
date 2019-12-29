module router_fsm(input clk,resetn,packet_valid,
				  input [1:0] datain,
				  input fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, low_packet_valid, 
				  output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
				  
 parameter  decode_address		=	4'b0001,
			wait_till_empty		=	4'b0010,
			load_first_data		=	4'b0011,
			load_data			=	4'b0100,
			load_parity			=	4'b0101,
			fifo_full_state		=	4'b0110,
			load_after_full		=	4'b0111,
			check_parity_error	=	4'b1000;
			
reg [3:0] present_state, next_state;
reg [1:0] temp;
//-------------------------------------------------------------------------------------------------------------------------------------------
//temp logic
always@(posedge clk)
	begin
		if(~resetn)
			temp<=2'b0;
		else if(detect_add)          // decides the address of out channel
		 	temp<=datain;
	end
//--------------------------------------------------------------------------------------------------------------------------------------------
// reset logic for states
always@(posedge clk)
	begin
		if(!resetn)
				present_state<=decode_address;  // hard reset
		else if (((soft_reset_0) && (temp==2'b00)) || ((soft_reset_1) && (temp==2'b01)) || ((soft_reset_2) && (temp==2'b10)))		//if there is soft_reset and also using same channel so we do here and opertion
				 
				present_state<=decode_address;

		else
				present_state<=next_state;
			
	end
//-------------------------------------------------------------------------------------------------------------------------------------------	
//state machine logic 

always@(*)
	begin
		case(present_state)
		decode_address:   // decode address state 
		begin
			if((packet_valid && (datain==2'b00) && fifo_empty_0)|| (packet_valid && (datain==2'b01) && fifo_empty_1)|| (packet_valid && (datain==2'b10) && fifo_empty_2))

					next_state<=load_first_data;   //lfd_state

			else if((packet_valid && (datain==2'b00) && !fifo_empty_0)||(packet_valid && (datain==2'b01) && !fifo_empty_1)||(packet_valid && (datain==2'b10) && !fifo_empty_2))
					next_state<=wait_till_empty;  //wait till empty state
				
			else 
				next_state<=decode_address;	   // same state
		end
//------------------------------------------------------------------------------------------------------------------------------------------
		load_first_data: 			// load first data state
		begin	
			next_state<=load_data;
		end
//-----------------------------------------------------------------------------------------------------------------------------------------
		wait_till_empty:          //wait till empty state
		begin
			if((fifo_empty_0 && (temp==2'b00))||(fifo_empty_1 && (temp==2'b01))||(fifo_empty_2 && (temp==2'b10))) //fifo is empty and were using same fifo
					next_state<=load_first_data;
	
				else
					next_state<=wait_till_empty;
			end
//-----------------------------------------------------------------------------------------------------------------------------------------
		load_data:                        //load data
		begin
			if(fifo_full==1'b1) 
					next_state<=fifo_full_state;
			else 
					begin
						if (!fifo_full && !packet_valid)
							next_state<=load_parity;
						else
							next_state<=load_data;
					end
		end
//--------------------------------------------------------------------------------------------------------------------------------------------
			fifo_full_state:			//fifo full state
			begin
				if(fifo_full==0)
					next_state<=load_after_full;
				else 
					next_state<=fifo_full_state;
			end
//-------------------------------------------------------------------------------------------------------------------------------------------
			load_after_full:         	// load after full state
			begin
				if(!parity_done && low_packet_valid)
					next_state<=load_parity;
				else if(!parity_done && !low_packet_valid)
					next_state<=load_data;
	
				else 
					begin 
						if(parity_done==1'b1)
							next_state<=decode_address;
						else
							next_state<=load_after_full;
					end
				
			end
//-------------------------------------------------------------------------------------------------------------------------------------------
			load_parity:                 // load parity state
			begin
				next_state<=check_parity_error;
			end
//-------------------------------------------------------------------------------------------------------------------------------------------
			check_parity_error:			// check parity error
			begin
				if(!fifo_full)
					next_state<=decode_address;
				else
					next_state<=fifo_full_state;
			end
//--------------------------------------------------------------------------------------------------------------------------------------------
			default:					//default state
				next_state<=decode_address; 

		endcase																					// state machine completed
	end
//----------------------------------------------------------------------------------------------------------------------------------------
// output logic


assign busy=((present_state==load_first_data)||(present_state==load_parity)||(present_state==fifo_full_state)||(present_state==load_after_full)||(present_state==wait_till_empty)||(present_state==check_parity_error))?1:0;
assign detect_add=((present_state==decode_address))?1:0;
assign lfd_state=((present_state==load_first_data))?1:0;
assign ld_state=((present_state==load_data))?1:0;
assign write_enb_reg=((present_state==load_data)||(present_state==load_after_full)||(present_state==load_parity))?1:0;
assign full_state=((present_state==fifo_full_state))?1:0;
assign laf_state=((present_state==load_after_full))?1:0;
assign rst_int_reg=((present_state==check_parity_error))?1:0;

endmodule