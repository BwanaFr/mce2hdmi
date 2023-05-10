//Sample signal by oversampling it
module sampler
#(parameter NB_SAMPLES =  9     //Assuming aclk of 126Mhz and a pixel clock of 14.318MHz
    )
    (
        input wire clk,         //System clk
        input wire reset,       //Reset
        input wire data_in,     //Data input
        output reg data_out,    //Data output
        output reg data_valid   //Data output valid
    );

reg [5:0] oneCount;
reg [5:0] sampleCount;
reg skipOne;

always @(posedge clk ) begin
    if (reset) begin
        oneCount <= 0;
        sampleCount <= NB_SAMPLES;
        skipOne <= 0;
        data_valid <= 0;
    end
    else begin
        if (data_in) begin
            oneCount <= oneCount + 1;
        end
        sampleCount <= sampleCount -1;
        if (sampleCount == 0) begin
            if (skipOne) begin
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
            skipOne <= !skipOne;
            sampleCount <= skipOne ? (NB_SAMPLES-1) : NB_SAMPLES;
            data_valid <= 1;
            oneCount <= 0;
        end
        else
            data_valid <= 0;
    end
end

endmodule
