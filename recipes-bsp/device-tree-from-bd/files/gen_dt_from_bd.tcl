
# Copyright (c) 2021 Deutsches Elektronen-Synchrotron DESY

package require cmdline
package require yaml

set option {
    {hdf.arg	""			"hardware Definition file"}
    {processor.arg	""			"target processor"}
    {rp.arg		""			"repo path"}
    {pname.arg	""			"Project Name"}
    {ws.arg		""			"Work Space Path"}
    {arch.arg	"64"			"32/64 bit architecture"}
    {overlay.arg	"0"			"Create an overlay"}
    {out_dts.arg	""			"Output filename"}
    {axi_if.arg	""			"AXI interface"}
}

set usage  "xsct app.tcl <arguments>"
array set params [cmdline::getoptions argv $option $usage]

parray params

################################################################################
# utils

proc hsi_utils_add_new_dts_param { node  param_name param_value param_type {param_decription ""} } {
    if { $param_type != "boolean" && $param_type != "comment" && [llength $param_value] == 0 } {
        error "param_value can only be empty if the param_type is boolean, value is must for other data types"
    }
    if { $param_type == "boolean" && [llength $param_value] != 0 } {
                error "param_value can only be empty if the param_type is boolean"
        }
    common::set_property $param_name $param_value $node
    set param [common::get_property CONFIG.$param_name $node]
    common::set_property TYPE $param_type $param
    common::set_property DESC $param_decription $param
    return $param
}

################################################################################
# create DT

hsi::set_repo_path $params(rp)
hsi::open_hw_design $params(hdf)

set tree [hsi::create_dt_tree -dts_file $params(out_dts)]
set root_node [hsi::create_dt_node -name "/"]

if {$params(overlay)} {
    set bus_node [hsi::create_dt_node -name "fragment" -unit_addr 100 -object $root_node]
    hsi_utils_add_new_dts_param $bus_node "target" "amba" reference
    set bus_node [hsi::create_dt_node -name "__overlay__" -object $bus_node]
} else {
    set bus_node [hsi::create_dt_node -name "amba_app" -label "amba_app" -unit_addr 0 -object $root_node]
    hsi_utils_add_new_dts_param $bus_node "compatible" "simple-bus" string
    hsi_utils_add_new_dts_param $bus_node "ranges" "" boolean
}

################################################################################
# customizations based on the processor type (Zynq-7000 vs Zynq MPSoC)

if {$params(arch) == 64} {
    hsi_utils_add_new_dts_param $bus_node "#address-cells" "2" comment
    hsi_utils_add_new_dts_param $bus_node "#size-cells" "2" comment
}

if {$params(processor) == "ps7_cortexa9_0"} {
    set IRQ_OFFSET 29
    set IRQ_CTRL_NAME intc
} elseif {$params(processor) == "psu_cortexa53_0"} {
    set IRQ_OFFSET 89
    set IRQ_CTRL_NAME gic
}

if {$params(axi_if) == ""} {
    if {$params(processor) == "ps7_cortexa9_0"} {
        set AXI_IF "arm_m_axi"
    } elseif {$params(processor) == "psu_cortexa53_0"} {
        set AXI_IF "arm_fpd_m_axi"
    } else {
        puts "Unsupported processor ($params(arch))"
        exit 1
    }
} else {
    set AXI_IF $params(axi_if)
}

puts "IRQ_OFFSET    = ${IRQ_OFFSET}"
puts "IRQ_CTRL_NAME = ${IRQ_CTRL_NAME}"
puts "AXI_IF        = ${AXI_IF}"

################################################################################
# create two dicts with info on interrupts

set pl_ps_irq_ips [dict create]
set pl_ps_irq_names [dict create]

set pl_ps_irq_net [hsi::get_nets -of_object [hsi::get_ports inst_app_inst_app_system_app_i_pl_ps_irq]]
set pl_ps_irq_net_sink [hsi::get_cells -of_object [hsi::get_nets $pl_ps_irq_net ]]

if {[expr {$pl_ps_irq_net_sink ne ""}] && [string match -nocase [hsi::get_property IP_NAME $pl_ps_irq_net_sink] "xlconcat"]} {
    puts "PL PS IRQ: concat"
    set concat_nets [hsi::get_nets -of_object [hsi::get_cells $pl_ps_irq_net_sink]]
    foreach concat_net $concat_nets {
        puts "  dbg: concat_net  = $concat_nets"
        set port_in [hsi::get_pins -of_object $concat_net -filter {DIRECTION==I}]
        set port_out [hsi::get_pins -of_object $concat_net -filter {DIRECTION==O}]
        puts "  dbg:   port_in  = $port_in"
        puts "  dbg:   port_out = $port_out"
        set v [regexp {(?:\s|^)In([0-9]+)} $port_in match match_idx]
        puts "  dbg:     v = $v"
        if {$v} {
            puts "$concat_net -> $match_idx"
            set source_ips [hsi::get_cells -of_object $concat_net]
            puts "  dbg:       source_ips = $source_ips"
            puts "  dbg:       match_idx = $match_idx"
            foreach source_ip $source_ips {
                if ([expr {$source_ip != $pl_ps_irq_net_sink}]) {
                    puts "  $source_ip . $port_out"
                    set comp_name [hsi::get_property CONFIG.Component_Name [hsi::get_cells $source_ip]]
                    dict append pl_ps_irq_ips $comp_name $match_idx
                    dict append pl_ps_irq_names $comp_name $port_out
                }
            }
        }
    }
} else {
    puts "PL PS IRQ: direct IP"
    # not yet implemented
}


################################################################################

proc get_reg_from_base_size {base size} {
    global params

    if {[regexp -nocase {0x([0-9a-f]{9})} "$base" match]} {
        set temp $base
        set temp [string trimleft [string trimleft $temp 0] x]
        set len [string length $temp]
        set rem [expr {${len} - 8}]
        set high_base "0x[string range $temp $rem $len]"
        set low_base "0x[string range $temp 0 [expr {${rem} - 1}]]"
        set low_base [format 0x%08x $low_base]
        if {[regexp -nocase {0x([0-9a-f]{9})} "$size" match]} {
            set temp $size
            set temp [string trimleft [string trimleft $temp 0] x]
            set len [string length $temp]
            set rem [expr {${len} - 8}]
            set high_size "0x[string range $temp $rem $len]"
            set low_size  "0x[string range $temp 0 [expr {${rem} - 1}]]"
            set low_size [format 0x%08x $low_size]
            if {$params(arch) == 64} {
                set reg "$low_base $high_base $low_size $high_size"
            } elseif {$params(arch) == 32} {
                set reg "$high_base $high_size"
            } else {
                puts "Unsupported arch ($params(arch))"
                exit 1
            }
        } else {
            if {$params(arch) == 64} {
                set reg "$low_base $high_base 0x0 $size"
            } elseif {$params(arch) == 32} {
                set reg "$high_base $size"
            } else {
                puts "Unsupported arch ($params(arch))"
                exit 1
            }
        }
    } else {
        if {$params(arch) == 64} {
            set reg "0x0 $base 0x0 $size"
        } elseif {$params(arch) == 32} {
            set reg "$base $size"
        } else {
            puts "Unsupported arch ($params(arch))"
            exit 1
        }
    }

    return $reg
}


foreach cell [hsi::get_cells] {
    set comp_name [hsi::get_property CONFIG.Component_Name [hsi::get_cells $cell]]
    set is_in_app [string match "system_app*" $comp_name]
    # puts "$is_in_app : $cell"

    if {$is_in_app} {
        set mem_ranges [hsi::get_mem_ranges [hsi::get_cells $cell]]

        set mem ""
        foreach mem_range $mem_ranges {
            set mst_iface [hsi::get_property MASTER_INTERFACE $mem_range]
            if {[string match $AXI_IF $mst_iface]} {
                # puts "  $mst_iface"
                set mem $mem_range
            }
        }

        if {[expr {$mem ne ""}]} {

            set base [string tolower [hsi::get_property BASE_VALUE $mem]]
            set high [string tolower [hsi::get_property HIGH_VALUE $mem]]
            set size [format 0x%x [expr {${high} - ${base} + 1}]]
            set reg [get_reg_from_base_size $base $size]

            set ip_name [hsi::get_property HIER_NAME [hsi::get_cells $cell]]
            set unit_addr [string range $base 2 99]
            set comp_node [hsi::create_dt_node -name $ip_name -label $ip_name -unit_addr $unit_addr -object $bus_node]
            hsi_utils_add_new_dts_param $comp_node "compatible" "generic-uio" string
            hsi_utils_add_new_dts_param $comp_node "reg" "$reg" intlist

            # add interrupts (if they were detected before)
            if {[dict exists $pl_ps_irq_ips $comp_name]} {
                # on zynq mp
                # interrupt-names = "s2mm_introut";
                # interrupt-parent = <&gic>;
                # interrupts = <0 89 4>;

                # on zynq
                # interrupt-names = "iic2intc_irpt";
                # interrupt-parent = <&intc>;
                # interrupts = <0 29 4>;

                set irq_offs [dict get $pl_ps_irq_ips $comp_name]
                set irq_name [dict get $pl_ps_irq_names $comp_name]
                set irq_idx [expr {$irq_offs + ${IRQ_OFFSET}}]

                hsi_utils_add_new_dts_param $comp_node "interrupt-names" "$irq_name" string
                hsi_utils_add_new_dts_param $comp_node "interrupt-parent" "<&${IRQ_CTRL_NAME}>" string
                hsi_utils_add_new_dts_param $comp_node "interrupts" "0 $irq_idx 4" intlist

            }
        }
    }
}


hsi::create_sw_design dt1 -os device_tree -proc $params(processor)
hsi::generate_target -dir dts_app
