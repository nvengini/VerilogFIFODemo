`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2024 02:50:43 PM
// Design Name: 
// Module Name: FIFO_2_clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIFO_2_clock(
    input rx_clock,
    input tx_clock,
    input reset,
    input [7:0] rx_data,
    input rx_irq,
    input tx_irq,
    
    output reg [7:0]tx_data,
    output [3:0]write_pointer_out,
    output [3:0]read_pointer_out,
    output Empty_Flag,
    output Full_Flag
    );
    
    reg [3:0] write_pointer;
    reg [3:0] read_pointer;
    reg read_behind_write = 1'b1;
    reg write_wraparound = 1'b0;
    reg read_wraparound = 1'b0;
    
    reg [7:0] fifo [9:0];
    assign write_pointer_out = write_pointer;
    assign read_pointer_out = read_pointer;
    
    
    assign Empty_Flag = (write_wraparound == read_wraparound & (write_pointer == read_pointer) ); 
    assign Full_Flag = (write_wraparound != read_wraparound & (write_pointer == read_pointer) );
    always @ (posedge rx_clock or posedge reset) begin
        if (reset) begin
            fifo[0] <= 8'b0;
            fifo[1] <= 8'b0;
            fifo[2] <= 8'b0;
            fifo[3] <= 8'b0;
            fifo[4] <= 8'b0;
            fifo[5] <= 8'b0;
            fifo[6] <= 8'b0;
            fifo[7] <= 8'b0;
            
            write_pointer <= 4'b0;
            // read_pointer <= 4'b0;
            // read_behind_write <= 1'b1;
            write_wraparound = 1'b0;
        end else begin
            if (rx_irq & !Full_Flag) begin
                fifo[write_pointer] <= rx_data;
  
                if (write_pointer == 9) begin
                    write_pointer <= 4'b0;
                    // read_behind_write <= 1'b0;
                    write_wraparound <= ~write_wraparound;
                    
                end else begin
                    write_pointer <= write_pointer + 1'b1;
                end
            
            end 
      
        
        end
    
    end
    
    
    always @ (posedge tx_clock or posedge reset) begin
        if (reset) begin
            read_pointer <= 4'b0;
            read_wraparound <= 1'b0;
        end
        else begin 
        
            if (tx_irq & !Empty_Flag) begin
                tx_data <= fifo[read_pointer];
                
                if (read_pointer == 9) begin
                    read_pointer <= 0;
                    // read_behind_write <= 1'b1; 
                    read_wraparound <= ~read_wraparound; 
                end else begin
                    read_pointer <= read_pointer + 1;
                end
            
            end 
        end 
    
    end
    
endmodule
