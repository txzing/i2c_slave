# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  set RST_MS_MAX [ipgui::add_param $IPINST -name "RST_MS_MAX"]
  set_property tooltip {延时的ms时间} ${RST_MS_MAX}

}

proc update_PARAM_VALUE.RST_MS_MAX { PARAM_VALUE.RST_MS_MAX } {
	# Procedure called to update RST_MS_MAX when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RST_MS_MAX { PARAM_VALUE.RST_MS_MAX } {
	# Procedure called to validate RST_MS_MAX
	return true
}


proc update_MODELPARAM_VALUE.FREQ_HZ { MODELPARAM_VALUE.FREQ_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "FREQ_HZ". Setting updated value from the model parameter.
set_property value 100000000 ${MODELPARAM_VALUE.FREQ_HZ}
}

proc update_MODELPARAM_VALUE.RST_MS_MAX { MODELPARAM_VALUE.RST_MS_MAX PARAM_VALUE.RST_MS_MAX } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RST_MS_MAX}] ${MODELPARAM_VALUE.RST_MS_MAX}
}

