
/*
    ---bcd transfer
    input data:0~999,10bit binary
    outBCD: 3*4 bit bcd code
*/
module bcd_trans
(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire start,          // posedge start trans
    input wire [9:0] data,
    output wire [11:0] outBCD,
    output reg done
);

//-----------------------------------reg define
reg [3:0] shift_cnt;
reg [1:0] comp_status;

reg [19:0] shift_data;
reg        enable;
//-----------------------------------wire define

wire [3:0] bcd_one;
wire [3:0] bcd_ten;
wire [3:0] bcd_hud;

wire [3:0] bcd_add_one;
wire [3:0] bcd_add_ten;
wire [3:0] bcd_add_hud;
wire [11:0] bcd_after_add;

//------------------------------------assign
assign outBCD = shift_data[19:8];

assign bcd_one = outBCD[3:0];
assign bcd_ten = outBCD[7:4];
assign bcd_hud = outBCD[11:8];

assign bcd_add_one = (bcd_one > 4'd4)?(bcd_one + 4'd3):(bcd_one);
assign bcd_add_ten = (bcd_ten > 4'd4)?(bcd_ten + 4'd3):(bcd_ten);
assign bcd_add_hud = (bcd_hud > 4'd4)?(bcd_hud + 4'd3):(bcd_hud);

assign bcd_after_add = {bcd_add_hud,bcd_add_ten,bcd_add_one};

/*
always @(posedge sys_clk or negedge sys_rst_n) 
begin
    if(sys_rst_n == 1'b0)
        enable <= 1'b0;
    else if(start == 1'b1)
        enable <= 1'b1;
    else if(shift_cnt == 4'd9)
        enable <= 1'b0;
end
*/
//===== shift_cnt control =====
always @(posedge sys_clk or negedge sys_rst_n) 
begin
    if(sys_rst_n == 1'b0)
        shift_cnt <= 4'd0;
    else if(start == 1'b0)
        shift_cnt <= 4'd0;
    else if(shift_cnt == 4'd9)
        shift_cnt <= 4'd9;
    else 
        shift_cnt <= shift_cnt + 1'b1;   
end

//===== shift data=============
always @(posedge sys_clk or negedge sys_rst_n) 
begin
    if(sys_rst_n == 1'b0)
        shift_data <= 20'd0;
    else if( shift_cnt == 4'd0)
        shift_data <= {10'd0,data};
    else if(shift_cnt != 4'd9)
        shift_data <= {bcd_after_add[10:0],shift_data[7:0],1'b0};
    // else if( shift_cnt == 4'd9)
        // shift_data <= shift_data;
end

//===== done ===================
always @(posedge sys_clk or negedge sys_rst_n) 
begin
    if(sys_rst_n == 1'b0)
        done <= 1'b0;
    else if(shift_cnt == 4'd9)
        done <= 1'b1;
    else 
        done <= 1'b0;    
end

endmodule

