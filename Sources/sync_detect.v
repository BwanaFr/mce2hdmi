/**
    This module detects sync validity
    We can use the output reg to 
**/

module sync_detect
    #(parameter PULSE_SIZE_MIN = 10,    //Minimum number of clock cycles
      parameter PULSE_SIZE_MAX = 20,    //Maximum number of clock cycles
      parameter MAX_PERIOD = 100)       //Maximum number of clock between each sync pulse
(
    input  wire             CLK,            //Input clock
    input  wire             nRST,           //Asynchronous reset
    input  wire             SyncIn,         //Sync input signal

    output reg              SyncOut,        //Sync detected (only for one clock)
    output reg              SyncValid,      //Sync valid (detected in time)
    output reg              SyncPolarity    //Sync polarity (positive/negative)

);
    
    localparam      CNT_SIZE = $clog2(MAX_PERIOD+1);              //Clock counter width

    reg         [CNT_SIZE:0]  lastChangeCount;  //Counter of number of clocks until last state change
    reg         syncState;                      //Last state of the sync
    reg         [CNT_SIZE:0]  lastSyncCount;    //Number of clocks since last sync


always @ ( posedge CLK or negedge nRST ) begin
    if( !nRST ) begin
            lastChangeCount <= 0;    
            lastSyncCount <= 0;
            syncState <= SyncIn;
            SyncOut <= 1'b0;
            SyncValid <= 1'b0;
            SyncPolarity <= 1'b0;
            end
    else if(syncState != SyncIn) begin
        $display("Sync changed!");
        //Pulse changed
        if((lastChangeCount >= PULSE_SIZE_MIN) & (lastChangeCount <= PULSE_SIZE_MAX)) begin
            //Pulse seems valid (within range)
            SyncOut <= 1'b1;
            SyncPolarity <= syncState;
            lastChangeCount <= 0;
            lastSyncCount <= 0;
            if(lastSyncCount <= MAX_PERIOD) begin
                SyncValid <= 1'b1;
                end
            end
        else begin
            $display("Invalid pulse!");
            //Invalid pulse
            SyncOut = 1'b0;
            lastChangeCount <= 0;
            SyncValid <= 1'b0;
            end
        end
    else begin
        //No change
        if(lastSyncCount <= MAX_PERIOD) begin
            lastSyncCount <= lastSyncCount + 1'b1;
            lastChangeCount <= lastChangeCount + 1'b1;
            end
        else begin
            SyncValid <= 1'b0;
            end
        SyncOut <= 1'b0;
    end    
end

always @ ( posedge CLK or negedge nRST ) begin
    if(CLK) begin
        syncState <= SyncIn;
        end
end

endmodule