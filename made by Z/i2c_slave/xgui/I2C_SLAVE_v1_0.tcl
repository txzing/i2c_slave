# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "DEBOUNCE_LEN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "I2C_SLAVE_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "I2C_SLAVE_DAT_MODE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "I2C_SLAVE_REG_MODE" -parent ${Page_0}


}

proc update_PARAM_VALUE.DEBOUNCE_LEN { PARAM_VALUE.DEBOUNCE_LEN } {
	# Procedure called to update DEBOUNCE_LEN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEBOUNCE_LEN { PARAM_VALUE.DEBOUNCE_LEN } {
	# Procedure called to validate DEBOUNCE_LEN
	return true
}

proc update_PARAM_VALUE.I2C_SLAVE_ADDR { PARAM_VALUE.I2C_SLAVE_ADDR } {
	# Procedure called to update I2C_SLAVE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I2C_SLAVE_ADDR { PARAM_VALUE.I2C_SLAVE_ADDR } {
	# Procedure called to validate I2C_SLAVE_ADDR
	return true
}

proc update_PARAM_VALUE.I2C_SLAVE_DAT_MODE { PARAM_VALUE.I2C_SLAVE_DAT_MODE } {
	# Procedure called to update I2C_SLAVE_DAT_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I2C_SLAVE_DAT_MODE { PARAM_VALUE.I2C_SLAVE_DAT_MODE } {
	# Procedure called to validate I2C_SLAVE_DAT_MODE
	return true
}

proc update_PARAM_VALUE.I2C_SLAVE_REG_MODE { PARAM_VALUE.I2C_SLAVE_REG_MODE } {
	# Procedure called to update I2C_SLAVE_REG_MODE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I2C_SLAVE_REG_MODE { PARAM_VALUE.I2C_SLAVE_REG_MODE } {
	# Procedure called to validate I2C_SLAVE_REG_MODE
	return true
}


proc update_MODELPARAM_VALUE.I2C_SLAVE_ADDR { MODELPARAM_VALUE.I2C_SLAVE_ADDR PARAM_VALUE.I2C_SLAVE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I2C_SLAVE_ADDR}] ${MODELPARAM_VALUE.I2C_SLAVE_ADDR}
}

proc update_MODELPARAM_VALUE.I2C_SLAVE_REG_MODE { MODELPARAM_VALUE.I2C_SLAVE_REG_MODE PARAM_VALUE.I2C_SLAVE_REG_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I2C_SLAVE_REG_MODE}] ${MODELPARAM_VALUE.I2C_SLAVE_REG_MODE}
}

proc update_MODELPARAM_VALUE.I2C_SLAVE_DAT_MODE { MODELPARAM_VALUE.I2C_SLAVE_DAT_MODE PARAM_VALUE.I2C_SLAVE_DAT_MODE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I2C_SLAVE_DAT_MODE}] ${MODELPARAM_VALUE.I2C_SLAVE_DAT_MODE}
}

proc update_MODELPARAM_VALUE.DEBOUNCE_LEN { MODELPARAM_VALUE.DEBOUNCE_LEN PARAM_VALUE.DEBOUNCE_LEN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEBOUNCE_LEN}] ${MODELPARAM_VALUE.DEBOUNCE_LEN}
}

