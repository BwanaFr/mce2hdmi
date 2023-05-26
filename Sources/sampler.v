//Sample signals by oversampling the

module sampler_signal
#(
    parameter NB_SAMPLES =  9     //Assuming aclk of 126Mhz and a pixel clock of 14.318MHz
)
(
    input clk,
    input wire reset,
    input wire data_in,
    input wire skip_one,
    input wire[$clog2(NB_SAMPLES+1):0] sampleCount,
    output reg data_out
);

reg [$clog2(NB_SAMPLES+1):0] oneCount;


always @(posedge clk ) begin
    if (reset) begin
        oneCount <= 0;
    end
    else begin
        if (data_in) begin
            oneCount <= oneCount + 1;
        end
        if (sampleCount == 0) begin
            if (skip_one) begin
                if (oneCount > ((NB_SAMPLES-1) / 2))
                    data_out <= 1;
                else
                    data_out <= 0;
            end
            else begin
                if (oneCount > ((NB_SAMPLES-1) / 2))
                    data_out <= 1;
                else
                    data_out <= 0;                
            end
            oneCount <= 0;
        end
    end    
end
endmodule

module sampler
#(
    parameter NB_SAMPLES =  9,     //Assuming a clk of 126Mhz and a pixel clock of 14.318MHz
    parameter NB_CHANNELS = 1      //Number of channels
)
(
    input wire clk,                                 //System clk
    input wire reset,                               //Reset
    input wire [NB_CHANNELS-1 : 0] data_in,         //Data input
    output wire [NB_CHANNELS-1 : 0] data_out,       //Data output
    output reg data_valid                           //Data output valid
);

reg [$clog2(NB_SAMPLES+1):0] sampleCount;
reg skipOne;

genvar i;

generate
    for (i=0; i<NB_CHANNELS; i = i + 1) begin
        sampler_signal
        #(
            .NB_SAMPLES(NB_SAMPLES-1)
        ) sampler_sig (
            .clk(clk),
            .reset(reset),
            .data_in(data_in[i]),
            .skip_one(skipOne),
            .sampleCount(sampleCount),
            .data_out(data_out[i])
        );
    end
endgenerate

always @(posedge clk ) begin
    if (reset) begin
        sampleCount <= NB_SAMPLES-1;
        skipOne <= 0;
        data_valid <= 0;
    end
    else begin
        sampleCount <= sampleCount -1;
        if (sampleCount == 0) begin
            skipOne <= !skipOne;
            sampleCount <= skipOne ? (NB_SAMPLES-2) : NB_SAMPLES-1;
            data_valid <= 1;
        end
        else
            data_valid <= 0;
    end
end

endmodule
