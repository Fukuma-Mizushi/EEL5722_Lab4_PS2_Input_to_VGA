`timescale 1ns / 1ps

module font_gen
    (
        input wire clk,
        input wire video_on,
        input wire [9:0] pixel_x, pixel_y ,
        input wire [6:0] ascii,
        output reg [2:0] rgb_text
    );

    wire [10:0] rom_addr;
    wire [6:0] char_addr ;
    wire [3:0] row_addr;
    wire [2:0] bit_addr;
    wire [7:0] font_word;
    wire font_bit, text_bit_on;

    // instantiate font ROM
    font_rom font_unit (.clk(clk), .addr(rom_addr), .data(font_word));
    
    // font ROM interface
    assign char_addr = ascii;
    assign row_addr = pixel_y[3:0] ;
    assign rom_addr = {char_addr , row_addr};
    assign bit_addr = pixel_x[2:0] ;
    assign font_bit = font_word[~bit_addr] ;
    
    // "on" region limited to top-left corner
    assign text_bit_on = (pixel_x[9:3]==0 && pixel_y[9:5]==0) ? font_bit : 0;
    
    // rgb multiplexing circuit
    always @(*) begin
        if(~video_on)
            rgb_text = 3'b000; // blank
        else
            if (text_bit_on && (char_addr != 7'h0d))
                rgb_text = 3'b010; // green
            else
                rgb_text = 3'b000; // black
    end
    
endmodule