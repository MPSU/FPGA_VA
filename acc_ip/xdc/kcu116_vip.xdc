create_clock -period 10.000 -name pcie_clk [get_ports pcie_clk_p]


set_property PACKAGE_PIN V6        [get_ports "pcie_clk_n"] ;# Bank 225 - MGTREFCLK0N_225
set_property PACKAGE_PIN V7        [get_ports "pcie_clk_p"] ;# Bank 225 - MGTREFCLK0P_225


set_property PACKAGE_PIN AF6       [get_ports "pcie_txn[7]"] ;# Bank 224 - MGTYTXN0_224
set_property PACKAGE_PIN AE8       [get_ports "pcie_txn[6]"] ;# Bank 224 - MGTYTXN1_224
set_property PACKAGE_PIN AD6       [get_ports "pcie_txn[5]"] ;# Bank 224 - MGTYTXN2_224
set_property PACKAGE_PIN AC4       [get_ports "pcie_txn[4]"] ;# Bank 224 - MGTYTXN3_224
set_property PACKAGE_PIN AF7       [get_ports "pcie_txp[7]"] ;# Bank 224 - MGTYTXP0_224
set_property PACKAGE_PIN AE9       [get_ports "pcie_txp[6]"] ;# Bank 224 - MGTYTXP1_224
set_property PACKAGE_PIN AD7       [get_ports "pcie_txp[5]"] ;# Bank 224 - MGTYTXP2_224
set_property PACKAGE_PIN AC5       [get_ports "pcie_txp[4]"] ;# Bank 224 - MGTYTXP3_224


set_property PACKAGE_PIN AA4       [get_ports "pcie_txn[3]"] ;# Bank 225 - MGTYTXN0_225
set_property PACKAGE_PIN W4        [get_ports "pcie_txn[2]"] ;# Bank 225 - MGTYTXN1_225
set_property PACKAGE_PIN U4        [get_ports "pcie_txn[1]"] ;# Bank 225 - MGTYTXN2_225
set_property PACKAGE_PIN R4        [get_ports "pcie_txn[0]"] ;# Bank 225 - MGTYTXN3_225
set_property PACKAGE_PIN AA5       [get_ports "pcie_txp[3]"] ;# Bank 225 - MGTYTXP0_225
set_property PACKAGE_PIN W5        [get_ports "pcie_txp[2]"] ;# Bank 225 - MGTYTXP1_225
set_property PACKAGE_PIN U5        [get_ports "pcie_txp[1]"] ;# Bank 225 - MGTYTXP2_225
set_property PACKAGE_PIN R5        [get_ports "pcie_txp[0]"] ;# Bank 225 - MGTYTXP3_225


set_property PACKAGE_PIN AF1       [get_ports "pcie_rxn[7]"] ;# Bank 224 - MGTYRXN0_224
set_property PACKAGE_PIN AE3       [get_ports "pcie_rxn[6]"] ;# Bank 224 - MGTYRXN1_224
set_property PACKAGE_PIN AD1       [get_ports "pcie_rxn[5]"] ;# Bank 224 - MGTYRXN2_224
set_property PACKAGE_PIN AB1       [get_ports "pcie_rxn[4]"] ;# Bank 224 - MGTYRXN3_224
set_property PACKAGE_PIN AF2       [get_ports "pcie_rxp[7]"] ;# Bank 224 - MGTYRXP0_224
set_property PACKAGE_PIN AE4       [get_ports "pcie_rxp[6]"] ;# Bank 224 - MGTYRXP1_224
set_property PACKAGE_PIN AD2       [get_ports "pcie_rxp[5]"] ;# Bank 224 - MGTYRXP2_224
set_property PACKAGE_PIN AB2       [get_ports "pcie_rxp[4]"] ;# Bank 224 - MGTYRXP3_224

set_property PACKAGE_PIN Y1        [get_ports "pcie_rxn[3]"] ;# Bank 225 - MGTYRXN0_225
set_property PACKAGE_PIN V1        [get_ports "pcie_rxn[2]"] ;# Bank 225 - MGTYRXN1_225
set_property PACKAGE_PIN T1        [get_ports "pcie_rxn[1]"] ;# Bank 225 - MGTYRXN2_225
set_property PACKAGE_PIN P1        [get_ports "pcie_rxn[0]"] ;# Bank 225 - MGTYRXN3_225
set_property PACKAGE_PIN Y2        [get_ports "pcie_rxp[3]"] ;# Bank 225 - MGTYRXP0_225
set_property PACKAGE_PIN V2        [get_ports "pcie_rxp[2]"] ;# Bank 225 - MGTYRXP1_225
set_property PACKAGE_PIN T2        [get_ports "pcie_rxp[1]"] ;# Bank 225 - MGTYRXP2_225
set_property PACKAGE_PIN P2        [get_ports "pcie_rxp[0]"] ;# Bank 225 - MGTYRXP3_225


set_property PACKAGE_PIN T19       [get_ports "pcie_perst_ls"] ;# Bank  65 VCCO - VCC1V8   - IO_T3U_N12_PERSTN0_65
set_property IOSTANDARD  LVCMOS18  [get_ports "pcie_perst_ls"] ;# Bank  65 VCCO - VCC1V8   - IO_T3U_N12_PERSTN0_65
set_property PULLUP true [get_ports pcie_perst_ls]
set_false_path -from [get_ports pcie_perst_ls]


#set_property PACKAGE_PIN P19       [get_ports "pcie_wake_b_ls"] ;# Bank  65 VCCO - VCC1V8   - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
#set_property IOSTANDARD  LVCMOS18  [get_ports "pcie_wake_b_ls"] ;# Bank  65 VCCO - VCC1V8   - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
