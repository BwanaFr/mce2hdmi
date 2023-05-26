/**
    This module detects sync signals within specs
    CGA sync pulses are (form what I measured, with my logic analyser):
    - V sync : 1019us positive pulse every 16.68ms
    - H sync : 4.4us positive pulse every 63.7us
    Default values are given for a 126mhz clock
    TODO: Count lines for V sync to reduce counter size
**/

module sync_detect
    #(parameter V_PULSE_SIZE_MIN = 127260,      //Minimum number of clock cycles for V sync (1010 us)
      parameter V_PULSE_SIZE_MAX = 129780,      //Maximum number of clock cycles for V sync (1030 us)
      parameter V_MAX_LINES = 263,              //Maximum number of lines in V period
      parameter H_PULSE_SIZE_MIN = 504,         //Minimum number of clock cycles for H sync (4 us)
      parameter H_PULSE_SIZE_MAX = 630,         //Maximum number of clock cycles for H sync (5 us)
      parameter H_MAX_PERIOD = 8190,            //Maximum number of clock between each sync pulse (65 us)
      parameter V_POLARITY = 1,                 //Vertical polarity
      parameter H_POLARITY = 1                  //Horizontal polarity
      )            
(
    input  wire             CLK,            //Input clock
    input  wire             nRST,           //Asynchronous reset
    input  wire             vSyncIn,        //Vertical sync input signal
    input  wire             hSyncIn,        //Horizontal sync input signal

    output reg              vSyncOut,        //V sync pulse
    output reg              hSyncOut,        //H sync pulse
    output wire             syncOk           //Sync detected (detected in time)
);
    
    localparam      PERIOD_CNT_SIZE = $clog2(H_MAX_PERIOD+1);       //Size of the h sync period counter
    localparam      LINE_CNT_SIZE = $clog2(V_MAX_LINES+1);          //Size of the lines counter
    localparam      V_SYNC_CNT_SIZE = $clog2(V_PULSE_SIZE_MAX+1);   //Size of the v syhnc pulse duration counter
    localparam      H_SYNC_CNT_SIZE = $clog2(H_PULSE_SIZE_MAX+1);   //Size of the h syhnc pulse duration counter

    reg         [LINE_CNT_SIZE:0] linesCount;       //Counter of lines between V
    reg         [PERIOD_CNT_SIZE:0] hPeriodCount;   //Counter of h sync period
    reg         [V_SYNC_CNT_SIZE:0] vSyncCount;     //Counter of v sync pulse
    reg         [H_SYNC_CNT_SIZE:0] hSyncCount;     //Counter of h sync pulse

    reg         prevVSync;  //Previous V sync state
    reg         prevHSync;  //Previous H sync state
    reg         vSyncOk;    //V sync is ok
    reg         hSyncOk;    //H sync is ok


assign syncOk = (hPeriodCount < H_MAX_PERIOD) & vSyncOk & hSyncOk & (linesCount < V_MAX_LINES);

//Sync detection for V sync
always @ ( posedge CLK or negedge nRST ) begin
    if( !nRST ) begin
        vSyncOk <= 1'b0;
        vSyncCount <= 0;
        vSyncOut <= 1'b0;
    end
    else if(prevVSync != vSyncIn) begin
        if(vSyncIn == V_POLARITY) begin
            //Start counting
            vSyncCount <= 1;
            vSyncOut <= 1'b0;
            linesCount <= 1'b0;
        end
        else begin
            //end of pulse
            if((vSyncCount >= V_PULSE_SIZE_MIN) & (vSyncCount <= V_PULSE_SIZE_MAX)) begin
                //Pulse width match what do we expect
                vSyncOk <= 1'b1;
                vSyncOut <= 1'b1;
            end
        end
    end
    else if(vSyncIn == V_POLARITY) begin
        //Pulse active, count
        vSyncOut <= 1'b0;
        if(vSyncCount <= V_PULSE_SIZE_MAX) begin
            //Pulse still within range
            vSyncCount <= vSyncCount + 1;
        end
        else begin
            //Pulse too long, not valid
            vSyncOk <= 1'b0;
        end
    end
    else begin
        vSyncOut <= 1'b0;
    end
end

//Sync detection for H sync
always @ ( posedge CLK or negedge nRST ) begin
    if( !nRST ) begin
        hSyncOk <= 1'b0;
        hSyncCount <= 0;
        hSyncOut <= 1'b0;
        hPeriodCount <= 0;
    end
    else if(prevHSync != hSyncIn) begin
        if(hSyncIn == H_POLARITY) begin
            //Start counting
            hSyncCount <= 1;
            hSyncOut <= 1'b0;
            hPeriodCount <= 0;
            if(linesCount < V_MAX_LINES) begin
                linesCount <= linesCount + 1;
            end
        end
        else begin
            //end of pulse
            if((hSyncCount >= H_PULSE_SIZE_MIN) & (hSyncCount <= H_PULSE_SIZE_MAX)) begin
                //Pulse width match what do we expect
                hSyncOk <= 1'b1;
                hSyncOut <= 1'b1;
            end
        end
    end
    else if(hSyncIn == H_POLARITY) begin
        //Pulse active, count
        hSyncOut <= 1'b0;
        if(hSyncCount <= H_PULSE_SIZE_MAX) begin
            //Pulse still within range
            hSyncCount <= hSyncCount + 1;
        end
        else begin
            //Pulse too long, not valid
            hSyncOk <= 1'b0;
        end
    end
    else begin
        hSyncOut <= 1'b0;
        if(hPeriodCount < H_MAX_PERIOD) begin
            hPeriodCount <= hPeriodCount + 1;
        end
    end
end

//Remember last sync state
always @ ( posedge CLK or negedge nRST ) begin
    if( !nRST ) begin
        prevVSync <= !V_POLARITY;
        prevHSync <= !H_POLARITY;
    end
    else if(CLK) begin
        prevVSync <= vSyncIn;
        prevHSync <= hSyncIn;
    end
end

endmodule