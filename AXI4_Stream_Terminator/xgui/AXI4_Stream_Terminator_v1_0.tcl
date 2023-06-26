# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NUM_VIDEO_COMPONENTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SAMPLES_PER_CLOCK" -parent ${Page_0} -widget comboBox
  ipgui::add_param $IPINST -name "MAXIMUM_DATA_WIDTH" -parent ${Page_0} -widget comboBox


}

proc update_PARAM_VALUE.MAXIMUM_DATA_WIDTH { PARAM_VALUE.MAXIMUM_DATA_WIDTH } {
	# Procedure called to update MAXIMUM_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAXIMUM_DATA_WIDTH { PARAM_VALUE.MAXIMUM_DATA_WIDTH } {
	# Procedure called to validate MAXIMUM_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.NUM_VIDEO_COMPONENTS { PARAM_VALUE.NUM_VIDEO_COMPONENTS } {
	# Procedure called to update NUM_VIDEO_COMPONENTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_VIDEO_COMPONENTS { PARAM_VALUE.NUM_VIDEO_COMPONENTS } {
	# Procedure called to validate NUM_VIDEO_COMPONENTS
	return true
}

proc update_PARAM_VALUE.SAMPLES_PER_CLOCK { PARAM_VALUE.SAMPLES_PER_CLOCK } {
	# Procedure called to update SAMPLES_PER_CLOCK when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SAMPLES_PER_CLOCK { PARAM_VALUE.SAMPLES_PER_CLOCK } {
	# Procedure called to validate SAMPLES_PER_CLOCK
	return true
}


proc update_MODELPARAM_VALUE.NUM_VIDEO_COMPONENTS { MODELPARAM_VALUE.NUM_VIDEO_COMPONENTS PARAM_VALUE.NUM_VIDEO_COMPONENTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_VIDEO_COMPONENTS}] ${MODELPARAM_VALUE.NUM_VIDEO_COMPONENTS}
}

proc update_MODELPARAM_VALUE.SAMPLES_PER_CLOCK { MODELPARAM_VALUE.SAMPLES_PER_CLOCK PARAM_VALUE.SAMPLES_PER_CLOCK } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SAMPLES_PER_CLOCK}] ${MODELPARAM_VALUE.SAMPLES_PER_CLOCK}
}

proc update_MODELPARAM_VALUE.MAXIMUM_DATA_WIDTH { MODELPARAM_VALUE.MAXIMUM_DATA_WIDTH PARAM_VALUE.MAXIMUM_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAXIMUM_DATA_WIDTH}] ${MODELPARAM_VALUE.MAXIMUM_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.MAXIMUM_NUMBER_OF_COLUMNS { MODELPARAM_VALUE.MAXIMUM_NUMBER_OF_COLUMNS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "MAXIMUM_NUMBER_OF_COLUMNS". Setting updated value from the model parameter.
set_property value 1280 ${MODELPARAM_VALUE.MAXIMUM_NUMBER_OF_COLUMNS}
}

proc update_MODELPARAM_VALUE.MAXIMUM_NUMBER_OF_ROWS { MODELPARAM_VALUE.MAXIMUM_NUMBER_OF_ROWS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "MAXIMUM_NUMBER_OF_ROWS". Setting updated value from the model parameter.
set_property value 720 ${MODELPARAM_VALUE.MAXIMUM_NUMBER_OF_ROWS}
}

proc update_MODELPARAM_VALUE.BAYER_PATTERN { MODELPARAM_VALUE.BAYER_PATTERN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	# WARNING: There is no corresponding user parameter named "BAYER_PATTERN". Setting updated value from the model parameter.
set_property value RGGB ${MODELPARAM_VALUE.BAYER_PATTERN}
}

