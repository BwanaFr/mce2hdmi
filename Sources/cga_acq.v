/**
    Acquires CGA signals

**/

module cga_acq
#(
    parameter NB_LINES = 200,       //Vertical resolution    
    parameter V_BACK_PORCH = 21,    //Number of lines before active video
    parameter V_FRONT_PORCH = 27,   //Number of lines after active video
    parameter V_SYNC_PULSE = 16,    //Number of lines of V sync

    parameter NB_COLS = 640,        //Horizontal resolution
    parameter H_BACK_PORCH = 110,   //Number of pixel clocks before active video
    parameter H_FRONT_PORCH = 98,   //Number of pixel clocks before active video
    parameter H_SYNC_PULSE = 63     //H sync width pixels
)
(
    input clk,                  //FPGA clock
    input wire nRST,            //Reset signal
    input wire enable,          //Module enabled
    input wire red,             //Red input (from sampler module)
    input wire green,           //Green input (from sampler module)
    input wire blue,            //Blue input (from sampler module)
    input wire intensity,       //Intensity input
    input wire vSync,           //Vertical synchro input (from sync_detect)
    input wire hSync,           //Horizontal synchro input
    
    output wire activeVideo     //Video is active
);

localparam V_TOTAL = V_BACK_PORCH + NB_LINES + V_FRONT_PORCH + V_SYNC_PULSE;
localparam H_TOTAL = H_BACK_PORCH + NB_COLS + H_FRONT_PORCH + H_SYNC_PULSE;

localparam LINES_CNT_SIZE = $clog2(V_BACK_PORCH + NB_LINES + 1);       //Number of interesting lines
localparam PIXEL_CNT_SIZE = $clog2(H_BACK_PORCH + NB_COLS + 1);       //Number of interesting pixels

reg [LINES_CNT_SIZE:0] activeLine;       //Counter of lines
reg [PIXEL_CNT_SIZE:0] activePixel;      //Counter of pixels

//Video is active only when back porches are over and in visible area
assign activeVideo = (activeLine > V_BACK_PORCH) & (activeLine < (V_BACK_PORCH + NB_LINES)) & (activePixel > H_BACK_PORCH) & (activePixel < (H_BACK_PORCH + NB_COLS));

//Sampler output
wire signalLatch;
wire fRed;
wire fGreen;
wire fBlue;
wire fIntensity;

//Instantiate a sampler to get filtered signals
sampler #( .NB_CHANNELS(4)) cga_sampler (
    .clk(clk),
    .reset(hSync),  //Resync sampler every horizontal pulse
    .data_in({red, green, blue, intensity}),
    .data_out({fRed, fGreen, fBlue, fIntensity}),
    .data_valid(signalLatch)
);


always @(posedge clk or negedge nRST ) begin
    if( !nRST ) begin
        //Reset
        activeLine <= 0;
        activePixel <= 0;
    end
    else begin
        if(hSync) begin
            activePixel <= 1;
        end
        if(vSync) begin
            activeLine <= 1;
        end
    end
end

endmodule