`timescale 1ns / 1ps

module sync_detect_tb ();
    reg rst;

    wire hs;            //Horizontal sync
    wire vs;            //Vertical sync
    wire intensity;      //Intensity
    wire red;            //Red
    wire green;          //Green
    wire blue;            //Blue
    wire px_clock;      //Pixel clock

    wire SyncOut;
    wire SyncValid;
    wire SyncPolarity;

cga_gen_tb cga (
    .hs(hs),
    .vs(vs),
    .intensity(intensity),
    .red(red),
    .green(green),
    .blue(blue),
    .pixel_clk(px_clock)
);

sync_detect #(.PULSE_SIZE_MIN(55), .PULSE_SIZE_MAX(60), .MAX_PERIOD(909)) dut (
    .CLK(px_clock),
    .nRST(rst),
    .SyncIn(hs),
    .SyncOut(SyncOut),
    .SyncValid(SyncValid),
    .SyncPolarity(SyncPolarity)
);

initial begin
   rst = 1'b0;
   #10
   rst = 1'b1;
end

endmodule