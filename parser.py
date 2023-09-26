# WIP
# Script, that parse DUT and testbench modules and generates
# testbench that will use FPGA accelerator

import re
# import regex

with open("dut_example/rtl/inverse.sv", "r") as fd:
  file_content = fd.read()
  # Trim file content to just module header
  start_module_position = file_content.find("module ")
  end_module_position = file_content.find(");") + 2
  file_content = file_content[start_module_position:end_module_position]
  print(file_content)

  # Get name of the module
  module_name = re.match("module\s+(\w+)\s*#?\(", file_content).group(1)
  print("Module name is '{}'\n".format(module_name))

  # Parse parameters block
  # First of all we need to check whether parameters at all
  # Then, we need to get list of pairs param_name, param_value
  # Next, we need to compute all param_value expressions.
  # To do so, first we collect all computed params (params which value expr
  # contains number only).
  # Then we discard all parameters that have quotes or dotes (string or float
  # values) because we search for parameters that can be used as port range
  # value.
  # Then we going through remain params one by one and trying to substitute
  # computed param names with their values and compute new expr.
  # If it simplified to number, we move this parameter into computed list

  # TODO:
  # Remove comments
  if "#" in file_content:
    hash_pos = re.search("#\s*\(", file_content).end()
    end_param_pos = re.search("\)\s*\(", file_content).start()
    parameters_string_list = file_content[hash_pos:end_param_pos].split(",")
    print(parameters_string_list)
    parameter_list_computed = []
    parameter_list_uncomputed = []
    for param_str in parameters_string_list:
      param_name, param_value = re.match(
          ".*parameter\s+(\w+)\s*=\s*(.*)", param_str, re.DOTALL).group(1, 2)
      param_value = re.sub('[\s+]', '', param_value)
      if param_value.isdigit():
        parameter_list_computed.append((param_name, param_value))
      elif ("\"" not in param_value) and ("." not in param_value):
        parameter_list_uncomputed.append((param_name, param_value))

