`timescale 1ns / 1ps


module cga_gen_tb(
    output wire hs,            //Horizontal sync
    output wire vs,            //Vertical sync
    output wire intensity,      //Intensity
    output wire red,            //Red
    output wire green,          //Green
    output wire blue,           //Blue
    output reg pixel_clk       //Pixel clock
);
    reg rst;
    
    wire active_video;  //Video is active

    integer in, ret;         //Input file

    reg[3:0] rgbi;

assign intensity = rgbi[3];
assign red = rgbi[2];
assign green = rgbi[1];
assign blue = rgbi[0];

cga_gen dut(
    .rst_n(rst),                    //Reset
    .pix_clk(pixel_clk),            //Pixel clock
    .hs(hs),                        //Horizontal sync
    .vs(vs),                        //Vertical sync
    .active_video(active_video)     //Active video
);

//Reset generation
initial begin
   rst = 1'b0;
   rgbi = 0;
   #100
   rst = 1'b1;
end

//Pixel clock
initial begin
     pixel_clk = 1'b0;
     forever #34.92 pixel_clk = ~pixel_clk;
end

//File readout
initial begin
    in = $fopen(".\\prince_cga.txt", "r");
    $display("File open %d", in);
end


always @(posedge pixel_clk)
begin
    if(active_video)
    begin
        ret = $fscanf(in, "%b\n", rgbi);
    end
end
endmodule
