# 1. Overclocked Clocks (2.5ns = 400 MHz, 4.5ns = 222 MHz)
create_clock -name wclk -period 2.5 [get_ports wclk]
create_clock -name rclk -period 4.5 [get_ports rclk]

# 2. Asynchronous Clock Groups
set_clock_groups -asynchronous -group [get_clocks wclk] -group [get_clocks rclk]

# 3. Aggressive Write Domain I/O Delays (20% of 1.0ns = 0.2ns)
set_input_delay -clock [get_clocks wclk] 0.2 [get_ports {wrst_n winc wdata}]
set_output_delay -clock [get_clocks wclk] 0.2 [get_ports wfull]

# 4. Aggressive Read Domain I/O Delays (20% of 2.0ns = 0.4ns)
set_input_delay -clock [get_clocks rclk] 0.4 [get_ports {rrst_n rinc}]
set_output_delay -clock [get_clocks rclk] 0.4 [get_ports {rempty rdata}]