`timescale 1ns / 1ps


module cga_acq_tb(
    output reg pixel_clk,       //Pixel clock
    output wire active_video    //Video is active
);
reg rst;

wire gen_video_active;

wire hs;             //Horizontal sync
wire vs;             //Vertical sync
wire intensity;      //Intensity
wire red;            //Red
wire green;          //Green
wire blue;           //Blue

wire vSyncOut;       //Horizontal sync
wire hSyncOut;       //Vertical sync
wire syncOk;         //Sync detected

integer in, ret;         //Input file

reg[3:0] rgbi;
assign intensity = rgbi[3];
assign red = rgbi[2];
assign green = rgbi[1];
assign blue = rgbi[0];

//Video timings generation
cga_gen vid_gen(
    .rst_n(rst),                    //Reset
    .pix_clk(pixel_clk),            //Pixel clock
    .hs(hs),                        //Horizontal sync
    .vs(vs),                        //Vertical sync
    .active_video(gen_video_active)
);

//Synchro detector
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
    .CLK(pixel_clk),
    .nRST(rst),
    .vSyncIn(vs),
    .hSyncIn(hs),
    .vSyncOut(vSyncOut),
    .hSyncOut(hSyncOut),
    .syncOk(syncOk)
);


cga_acq cga_aqn(
    .clk(pixel_clk),            //FPGA clock
    .nRST(rst),                 //Reset signal
    .enable(syncOk),            //Module enabled
    .red(red),                  //Red input (from sampler module)
    .green(green),               //Green input (from sampler module)
    .blue(blue),                //Blue input (from sampler module)
    .intensity(intensity),      //Intensity input
    .vSync(vSyncOut),           //Vertical synchro input (from sync_detect)
    .hSync(hSyncOut),           //H sync
    .activeVideo(active_video)
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
    if(gen_video_active)
    begin
        ret = $fscanf(in, "%b\n", rgbi);
    end
end
endmodule
