`timescale 1ns/1ps

module CPU_test;

    reg clock;
    parameter interval = 10;
    integer file;
    integer i;

    CPU dut(
        .CLK(clock)
    );

    initial begin
        clock=0;
        i = 0;  

        while(dut.InstrD != 32'hFFFFFFFF)
        begin
            #interval; 
        end

        #50     
        file = $fopen("data.bin","wb");
        while(i!=512) begin
            $display("%b", dut.data_ram.DATA_RAM[i]);
            $fwrite(file,"%b\n", dut.data_ram.DATA_RAM[i]);
            i = i + 1;
        end
        $finish;
    end

    always begin
        #(interval / 2)
        clock = ~clock;
    end

endmodule