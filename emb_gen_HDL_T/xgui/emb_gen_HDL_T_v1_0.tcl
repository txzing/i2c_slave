# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "EMB_TYPE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RAW12_TYPE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "H_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "V_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRONT_LINE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TAIL_LINE" -parent ${Page_0}


}

proc update_PARAM_VALUE.EMB_TYPE { PARAM_VALUE.EMB_TYPE } {
	# Procedure called to update EMB_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.EMB_TYPE { PARAM_VALUE.EMB_TYPE } {
	# Procedure called to validate EMB_TYPE
	return true
}

proc update_PARAM_VALUE.FREQ_HZ { PARAM_VALUE.FREQ_HZ } {
	# Procedure called to update FREQ_HZ when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FREQ_HZ { PARAM_VALUE.FREQ_HZ } {
	# Procedure called to validate FREQ_HZ
	return true
}

proc update_PARAM_VALUE.FRONT_LINE { PARAM_VALUE.FRONT_LINE } {
	# Procedure called to update FRONT_LINE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRONT_LINE { PARAM_VALUE.FRONT_LINE } {
	# Procedure called to validate FRONT_LINE
	return true
}

proc update_PARAM_VALUE.H_SIZE { PARAM_VALUE.H_SIZE } {
	# Procedure called to update H_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.H_SIZE { PARAM_VALUE.H_SIZE } {
	# Procedure called to validate H_SIZE
	return true
}

proc update_PARAM_VALUE.RAW12_TYPE { PARAM_VALUE.RAW12_TYPE } {
	# Procedure called to update RAW12_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RAW12_TYPE { PARAM_VALUE.RAW12_TYPE } {
	# Procedure called to validate RAW12_TYPE
	return true
}

proc update_PARAM_VALUE.TAIL_LINE { PARAM_VALUE.TAIL_LINE } {
	# Procedure called to update TAIL_LINE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TAIL_LINE { PARAM_VALUE.TAIL_LINE } {
	# Procedure called to validate TAIL_LINE
	return true
}

proc update_PARAM_VALUE.V_SIZE { PARAM_VALUE.V_SIZE } {
	# Procedure called to update V_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.V_SIZE { PARAM_VALUE.V_SIZE } {
	# Procedure called to validate V_SIZE
	return true
}


proc update_MODELPARAM_VALUE.EMB_TYPE { MODELPARAM_VALUE.EMB_TYPE PARAM_VALUE.EMB_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.EMB_TYPE}] ${MODELPARAM_VALUE.EMB_TYPE}
}

proc update_MODELPARAM_VALUE.RAW12_TYPE { MODELPARAM_VALUE.RAW12_TYPE PARAM_VALUE.RAW12_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RAW12_TYPE}] ${MODELPARAM_VALUE.RAW12_TYPE}
}

proc update_MODELPARAM_VALUE.H_SIZE { MODELPARAM_VALUE.H_SIZE PARAM_VALUE.H_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.H_SIZE}] ${MODELPARAM_VALUE.H_SIZE}
}

proc update_MODELPARAM_VALUE.V_SIZE { MODELPARAM_VALUE.V_SIZE PARAM_VALUE.V_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.V_SIZE}] ${MODELPARAM_VALUE.V_SIZE}
}

proc update_MODELPARAM_VALUE.FRONT_LINE { MODELPARAM_VALUE.FRONT_LINE PARAM_VALUE.FRONT_LINE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRONT_LINE}] ${MODELPARAM_VALUE.FRONT_LINE}
}

proc update_MODELPARAM_VALUE.TAIL_LINE { MODELPARAM_VALUE.TAIL_LINE PARAM_VALUE.TAIL_LINE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TAIL_LINE}] ${MODELPARAM_VALUE.TAIL_LINE}
}

proc update_MODELPARAM_VALUE.FREQ_HZ { MODELPARAM_VALUE.FREQ_HZ PARAM_VALUE.FREQ_HZ } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FREQ_HZ}] ${MODELPARAM_VALUE.FREQ_HZ}
}

