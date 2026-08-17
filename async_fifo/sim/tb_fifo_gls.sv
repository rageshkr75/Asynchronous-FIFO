`timescale 1ns / 1ps

module tb_fifo_gls;

   
    // 1. Clock & Control Signals 
    
    logic wclk = 0, rclk = 0;
    logic wrst_n = 0, rrst_n = 0;
    logic winc = 0, rinc = 0;
    logic [7:0] wdata = 0;

    logic VPWR = 1; // Power (1.8V nominal mapped to logic 1)
    logic VGND = 0; // Ground

    // --------------------------------------------------------
    // 3. Output Vectors (Separate for DUT and REF)
    // --------------------------------------------------------
    logic dut_wfull, dut_rempty;
    logic [7:0] dut_rdata;

    logic ref_wfull, ref_rempty;
    logic [7:0] ref_rdata;

    int error_count = 0;

    // --------------------------------------------------------
    // 4. Device Under Test (Physical Powered Netlist)
    // --------------------------------------------------------
    top_fifo dut (
        .VPWR(VPWR), .VGND(VGND), // Power hookups
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wdata(wdata), .wfull(dut_wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rdata(dut_rdata), .rempty(dut_rempty)
    );

    // --------------------------------------------------------
    // 5. Golden Reference Model (Behavioral Verilog)
    // --------------------------------------------------------
    beh_fifo ref_model (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wdata(wdata), .wfull(ref_wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rdata(ref_rdata), .rempty(ref_rempty)
    );

    // --------------------------------------------------------
    // 6. SDF Back-Annotation
    // --------------------------------------------------------
    `ifdef ENABLE_SDF
    initial begin
        $display("----------------------------------------");
        $display("[GLS] Annotating SDF Delays...");
        $display("----------------------------------------");
        
        $sdf_annotate("runs/RUN_2026.06.14_11.17.33/results/final/sdf/multicorner/nom/top_fifo.Typical.sdf", dut);
    end
    `endif

    // --------------------------------------------------------
    // 7. Clock Generation (400 MHz Write, 222 MHz Read)
    // --------------------------------------------------------
    always #1.25 wclk = ~wclk; 
    always #2.25 rclk = ~rclk; 

    // --------------------------------------------------------
    // 8. Continuous Assertion Monitor (The Oracle)
    // --------------------------------------------------------
    always @(negedge rclk) begin
        if (rinc && !dut_rempty) begin
            #0.1; // Small delay to allow signals to settle after clock edge
            
            // X-State Check (Crucial for physical timing violations)
            if ($isunknown(dut_rdata)) begin
                $error("[%0t] FATAL: X-State detected on DUT rdata!", $time);
                error_count++;
            end
            
            // Logic Mismatch Check against Golden Model
            if (dut_rdata !== ref_rdata) begin
                $error("[%0t] MISMATCH: REF Expected %h, DUT Got %h", $time, ref_rdata, dut_rdata);
                error_count++;
            end
        end
    end

    // --------------------------------------------------------
    // Main Test Sequence
    // --------------------------------------------------------
    initial begin
        $dumpfile("gls_waveform.vcd");
        $dumpvars(0, tb_fifo_gls);

        // --- PHASE 1: Sunburst Compliant Reset ---
        $display("[%0t] Phase 1: Asserting Resets...", $time);
        wrst_n = 0; rrst_n = 0;
        #20; 
        @(negedge wclk) wrst_n = 1;
        @(negedge rclk) rrst_n = 1;
        #50; 

        // --- PHASE 2: Sanity Fill (Write until full) ---
        $display("[%0t] Phase 2: Sanity Fill...", $time);
        while (!ref_wfull) begin
            @(negedge wclk);
            winc = 1;
            wdata = $urandom_range(0, 255);
        end
        @(negedge wclk) winc = 0;
        
        $display("[%0t] FIFO is FULL. Waiting for sync...", $time);
        #100; 

        // --- PHASE 3: Sanity Drain (Read until empty) ---
        $display("[%0t] Phase 3: Sanity Drain...", $time);
        while (!ref_rempty) begin
            @(negedge rclk);
            rinc = 1;
        end
        @(negedge rclk) rinc = 0;

        #100;

        // --- PHASE 4: Concurrent Stress Test ---
        $display("[%0t] Phase 4: Concurrent Read/Write Stress...", $time);
        fork
            // Write Thread
            begin
                repeat(50) begin
                    @(negedge wclk);
                    winc = (!dut_wfull && $urandom_range(0, 1)); 
                    if (winc) wdata = $urandom_range(0, 255);
                end
                @(negedge wclk) winc = 0;
            end
            
            // Read Thread
            begin
                repeat(30) begin 
                    @(negedge rclk);
                    rinc = (!dut_rempty && $urandom_range(0, 1)); 
                end
                @(negedge rclk) rinc = 0;
            end
        join

        #100;

        // --- PHASE 5: Final Signoff ---
        $display("----------------------------------------");
        if (error_count == 0)
            $display("TAPE OUT APPROVED: TEST STATUS PASSED");
        else
            $display("SILICON REJECTED: %0d Errors Detected", error_count);
        $display("----------------------------------------");
        
        $finish;
    end
endmodule
