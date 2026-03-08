module spi_peripheral(
    input wire copi,
    input wire ncs,
    input wire sclk,
    output wire [7:0] en_reg_out_7_0,
    output wire [7:0] en_reg_out_15_8,
    output wire [7:0] en_reg_pwm_7_0,
    output wire [7:0] en_reg_pwm_15_8,
    output wire [7:0] pwm_duty_cycle,
);



    always @(posedge sclk)



endmodule