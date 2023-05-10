`timescale 1ns / 1ps

module sampler_tb ();
    reg fpga_clk;
    reg rst;

    wire hs;            //Horizontal sync
    wire vs;            //Vertical sync
    wire intensity;      //Intensity
    wire red;            //Red
    wire green;          //Green
    wire blue;            //Blue
    wire px_clock;      //Pixel clock
    
cga_gen_tb cga (
    .hs(hs),
    .vs(vs),
    .intensity(intensity),
    .red(red),
    .green(green),
    .blue(blue),
    .pixel_clk(px_clock)
);

sampler dut (
    .clk(fpga_clk),
    .reset(rst),
    .data_in(red),
    .data_out(data_out),
    .data_valid(data_valid)
);

initial begin
   rst = 1'b1;
   #100
   rst = 1'b0;
end

initial begin
    fpga_clk = 1'b0;
    forever #3.968 fpga_clk = ~fpga_clk;
end

endmodule