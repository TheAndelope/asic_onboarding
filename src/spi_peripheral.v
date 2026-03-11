module spi_peripheral(
    input wire clk,
    input wire rst_n,
    input wire copi,
    input wire ncs,
    input wire sclk,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

    reg transaction_ready;
    reg transaction_processed;

    reg sclk_sync1;
    reg sclk_sync2;

    reg copi_sync1;
    reg copi_sync2;

    reg ncs_sync1;
    reg ncs_sync2;

    reg [15:0] buffer;
    reg [4:0] bit_count;

    wire ncs_posedge = ~ncs_sync2 & ncs_sync1;

    //dff synchronizers
    always @(posedge clk) begin
        sclk_sync1 <= sclk;
        sclk_sync2 <= sclk_sync1;

        copi_sync1 <= copi;
        copi_sync2 <= copi_sync1;

        ncs_sync1 <= ncs;
        ncs_sync2 <= ncs_sync1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            transaction_ready <= 1'b0;
            buffer <= {16{1'b0}};
            bit_count <= 0;
        end else if (ncs_posedge) begin
                transaction_ready <= 1'b1;
                bit_count <= 0;
        end else if (transaction_processed) begin
                transaction_ready <= 1'b0;
            
        end else if (ncs_sync2 == 1'b0) begin
            if(~sclk_sync2 & sclk_sync1) begin
                buffer <= {buffer[14:0], copi_sync2}; 
                bit_count <= bit_count + 1;
            end
        end 
    end

    // Update registers only after the complete transaction has finished and been validated
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            en_reg_out_7_0 <= {8{1'b0}};
            en_reg_out_15_8 <= {8{1'b0}};
            en_reg_pwm_7_0 <= {8{1'b0}};
            en_reg_pwm_15_8 <= {8{1'b0}};
            pwm_duty_cycle <= {8{1'b0}};
            transaction_processed <= 1'b0;
        end else if (transaction_ready && !transaction_processed && buffer[15]) begin
            // Transaction is ready and not yet processed
            case(buffer[14:8]) 
                7'h0: en_reg_out_7_0 <= buffer[7:0];
                7'h1: en_reg_out_15_8 <= buffer[7:0];
                7'h2: en_reg_pwm_7_0 <= buffer[7:0];
                7'h3: en_reg_pwm_15_8 <= buffer[7:0];
                7'h4: pwm_duty_cycle <= buffer[7:0];
                default: ;
            endcase
            // Set the processed flag
            transaction_processed <= 1'b1;
        end else if (!transaction_ready && transaction_processed) begin
            // Reset processed flag when ready flag is cleared
            transaction_processed <= 1'b0;
        end
    end

endmodule
