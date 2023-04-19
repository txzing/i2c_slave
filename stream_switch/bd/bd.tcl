
proc init { cellpath otherInfo } {                                                                   
                                                                                                             
	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
	set full_sbusif_list [list  ]
    put "axis_passthrough_monitor:init"
			                                                                                                 
	foreach busif $all_busif {                                                                               
		if { [string equal -nocase [get_property MODE $busif] "slave"] == 1 } { 
		    if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } { 
                if { [string equal -nocase [get_property NAME $busif] "s_axis"] == 1 } {
                    #set_property config.FREQ_HZ [get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $cell_handle/s_axis]]] $cell_handle
                    set_property CONFIG.FREQ_HZ.VALUE_SRC PROPAGATED [get_bd_pins $cell_handle/aclk]  
                    set_property config.FREQ_HZ [get_property config.FREQ_HZ [get_bd_intf_pins $cell_handle/s_axis]] $cell_handle
                    #put [get_property config.FREQ_HZ [get_bd_intf_pins $cell_handle/s_axis]]
                    #put [get_property config.FREQ_HZ $cell_handle]
		    put [format %s%s "config.FREQ_HZ=" [get_property config.FREQ_HZ $cell_handle]]
                }
                #set_property CONFIG.FREQ_HZ.VALUE_SRC PROPAGATED [get_bd_pins $cell_handle/aclk]          
		        #set_property config.FREQ_HZ [get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $busif]]] $cell_handle
		        #set_property -dict [list CONFIG.FREQ_HZ {[get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $busif]]]}] $cell_handle
			    continue                                                                                         
		    }                 
			set busif_param_list [list]                                                                      
			set busif_name [get_property NAME $busif]					                                     
			if { [lsearch -exact -nocase $full_sbusif_list $busif_name ] == -1 } {					         
			    continue                                                                                     
			}                                                                                                
			foreach tparam $axi_standard_param_list {                                                        
				lappend busif_param_list "C_${busif_name}_${tparam}"                                       
			}                                                                                                
			bd::mark_propagate_only $cell_handle $busif_param_list			                                 
		}		                                                                                             
	}                                                                                                        
}


proc pre_propagate {cellpath otherInfo } {                                                           
                                                                                                             
	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
    put "axis_passthrough_monitor:pre_propagate"
	                                                                                                         
	foreach busif $all_busif {
        #put $busif
        #put [get_property CONFIG.PROTOCOL $busif]                                                                          
		if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } {
            if { [string equal -nocase [get_property NAME $busif] "s_axis"] == 1 } {
                #put "here"
                #set_property config.FREQ_HZ [get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $cell_handle/s_axis]]] $cell_handle 
                if { [string equal [get_property config.FREQ_HZ [get_bd_intf_pins $cell_handle/s_axis]] ""] != 1 } {
			set_property config.FREQ_HZ [get_property config.FREQ_HZ [get_bd_intf_pins $cell_handle/s_axis]] $cell_handle
			put [format %s%s "config.FREQ_HZ=" [get_property config.FREQ_HZ $cell_handle]]
                }
		#put [get_property config.FREQ_HZ [get_bd_intf_pins $cell_handle/s_axis]]
                #put [get_property config.FREQ_HZ $cell_handle]
            }
		    #set_property config.FREQ_HZ [get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $busif]]] $cell_handle       
		    #set_property -dict [list CONFIG.FREQ_HZ {[get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $busif]]]}] $cell_handle           
			continue                                                                                         
		}                                                                                                    
		if { [string equal -nocase [get_property MODE $busif] "master"] != 1 } {                           
			continue                                                                                         
		}			                                                                                         
		                                                                                                     
		set busif_name [get_property NAME $busif]			                                                 
		foreach tparam $axi_standard_param_list {		                                                     
			set busif_param_name "C_${busif_name}_${tparam}"			                                     
			                                                                                                 
			set val_on_cell_intf_pin [get_property CONFIG.${tparam} $busif]                                  
			set val_on_cell [get_property CONFIG.${busif_param_name} $cell_handle]                           
			                                                                                                 
			if { [string equal -nocase $val_on_cell_intf_pin $val_on_cell] != 1 } {                          
				if { $val_on_cell != "" } {                                                                  
					set_property CONFIG.${tparam} $val_on_cell $busif                                        
				}                                                                                            
			}			                                                                                     
		}		                                                                                             
	}                                                                                                        
}


proc propagate {cellpath otherInfo } {                                                               
                                                                                                             
	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
    put "axis_passthrough_monitor:propagate"
	                                                                                                         
	foreach busif $all_busif {                                                                               
		if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } { 
            if { [string equal -nocase [get_property NAME $busif] "s_axis"] == 1 } {
                #set_property config.FREQ_HZ [get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $cell_handle/s_axis]]] $cell_handle 
                set_property config.FREQ_HZ [get_property config.FREQ_HZ [get_bd_intf_pins $cell_handle/s_axis]] $cell_handle
                #put [get_property config.FREQ_HZ [get_bd_intf_pins $cell_handle/s_axis]]
                #put [get_property config.FREQ_HZ $cell_handle]
		put [format %s%s "config.FREQ_HZ=" [get_property config.FREQ_HZ $cell_handle]]
            }
            #put $busif
		    #set_property config.FREQ_HZ [get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $busif]]] $cell_handle
		    #set_property -dict [list CONFIG.FREQ_HZ {[get_property config.FREQ_HZ [find_bd_objs –relation connected_to [get_bd_intf_pins $busif]]]}] $cell_handle                 
			continue                                                                                         
		}                                                                                                    
		if { [string equal -nocase [get_property MODE $busif] "slave"] != 1 } {                            
			continue                                                                                         
		}			                                                                                         
	                                                                                                         
		set busif_name [get_property NAME $busif]		                                                     
		foreach tparam $axi_standard_param_list {			                                                 
			set busif_param_name "C_${busif_name}_${tparam}"			                                     
                                                                                                             
			set val_on_cell_intf_pin [get_property CONFIG.${tparam} $busif]                                  
			set val_on_cell [get_property CONFIG.${busif_param_name} $cell_handle]                           
			                                                                                                 
			if { [string equal -nocase $val_on_cell_intf_pin $val_on_cell] != 1 } {                          
				#override property of bd_interface_net to bd_cell -- only for slaves.  May check for supported values..
				if { $val_on_cell_intf_pin != "" } {                                                         
					set_property CONFIG.${busif_param_name} $val_on_cell_intf_pin $cell_handle               
				}                                                                                            
			}                                                                                                
		}		                                                                                             
	}                                                                                                        
}

