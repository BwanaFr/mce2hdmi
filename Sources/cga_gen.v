
module cga_gen
#(// Horizontal
    parameter H_FRONT = 27, // Front porch
    parameter H_SYNC  = 57, // Sync
    parameter H_BACK  = 81, // Back porch
    parameter H_ACT   = 640,// Active pixels
    parameter H_BLANK = H_FRONT+H_SYNC+H_BACK, // Total blanking
    parameter H_TOTAL = H_FRONT+H_SYNC+H_BACK+H_ACT, // Total length

    // Vertical
    parameter V_FRONT = 20, // Front porch 
    parameter V_SYNC  = 3,  // Sync
    parameter V_BACK  = 40, // Back porch
    parameter V_ACT   = 200,// Active lines
    parameter V_BLANK = V_FRONT+V_SYNC+V_BACK, // Total blanking
    parameter V_TOTAL = V_FRONT+V_SYNC+V_BACK+V_ACT // Total length
)
(
    input wire rst_n,           //Reset
    input wire pix_clk,         //Pixel clock
    output reg hs,              //Horizontal sync
    output reg vs,              //Vertical sync
    output wire active_video    //Video active
);

reg [10:0] H_Cont;  //Horizontal counter
reg [10:0] V_Cont;  //Vertical counter
assign active_video = ((H_Cont>=H_BLANK && H_Cont<H_TOTAL)&&
                   (V_Cont>=V_BLANK && V_Cont<V_TOTAL));
                   
always @(posedge pix_clk or negedge rst_n)
begin
  if(!rst_n)
  begin
    H_Cont <= 0;
    hs <= 0;
  end
  else
  begin
    if(H_Cont<H_TOTAL)
        H_Cont <= H_Cont + 1'b1;
    else
        H_Cont <= 0;
    if(H_Cont==H_FRONT-1)
        hs <= 1'b1;
    if(H_Cont==H_FRONT+H_SYNC-1)
        hs <= 1'b0;
  end 
end

always@(posedge hs or negedge rst_n)
begin
  if(!rst_n)
  begin
    V_Cont <= 0;
    vs <= 0;
  end
  else
  begin
    if(V_Cont<V_TOTAL)
      V_Cont <= V_Cont+1'b1;
    else
      V_Cont <= 0;
    if(V_Cont==V_FRONT-1)
      vs <= 1'b1;
    if(V_Cont==V_FRONT+V_SYNC-1)
      vs <= 1'b0;
  end
end



endmodule