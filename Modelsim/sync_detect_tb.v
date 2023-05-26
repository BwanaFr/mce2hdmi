`timescale 1ns / 1ps

module sync_detect_tb ();
    reg rst;

    reg hs;            //Horizontal sync
    reg vs;            //Vertical sync
    reg clk;           //FPGA clock

    wire hSyncOut;
    wire vSyncOut;
    wire syncOk;

    integer i = 0;
    integer j = 0;

sync_detect #(
        .V_PULSE_SIZE_MIN(127260),
        .V_PULSE_SIZE_MAX(129780),
        .V_MAX_LINES(263),
        .H_PULSE_SIZE_MIN(504),
        .H_PULSE_SIZE_MAX(630),
        .H_MAX_PERIOD(8190),
        .V_POLARITY(1),
        .H_POLARITY(1)
    ) dut (
    .CLK(clk),
    .nRST(rst),
    .vSyncIn(vs),
    .hSyncIn(hs),
    .vSyncOut(vSyncOut),
    .hSyncOut(hSyncOut),
    .syncOk(syncOk)
);

initial begin
   rst = 1'b0;
   #10;
   rst = 1'b1;
end

// VS generation
initial begin
    vs = 1'b0;
    #20;
    for (i = 0; i < 5; i = i + 1) begin
        vs = 1'b1;
        #1019000;
        vs = 1'b0;
        #15669330;
    end
end

// HS generation
initial begin
    hs = 1'b0;
    #10;
    for (j = 0; j < 1800; j = j + 1) begin
        hs = 1'b1;
        #4410;
        hs = 1'b0;
        #59290;
    end
end

//Clock generation
initial begin
     clk = 1'b0;
     forever #3.96825 clk = ~clk;  //126 Mhz
end

endmodule