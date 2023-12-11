
echo "Generating Keccak+TRNG block data registers data RTL"
/home/valeria.piscopo/TRNG/x_heep/BASE/hw/vendor/esl_epfl_x_heep/hw/vendor/pulp_platform_register_interface/vendor/lowrisc_opentitan/util/regtool.py -r -t /home/valeria.piscopo/TRNG/src/regs /home/valeria.piscopo/TRNG/regs_gen/trng_keccak_data_regs.hjson
echo "Generating Keccak+TRNG block ctrl registers data RTL"
/home/valeria.piscopo/TRNG/x_heep/BASE/hw/vendor/esl_epfl_x_heep/hw/vendor/pulp_platform_register_interface/vendor/lowrisc_opentitan/util/regtool.py -r -t /home/valeria.piscopo/TRNG/src/regs /home/valeria.piscopo/TRNG/regs_gen/trng_keccak_ctrl_regs.hjson

echo "Generating Keccak+TRNG block data registers data SW"
/home/valeria.piscopo/TRNG/x_heep/BASE/hw/vendor/esl_epfl_x_heep/hw/vendor/pulp_platform_register_interface/vendor/lowrisc_opentitan/util/regtool.py --cdefines -o /home/valeria.piscopo/TRNG/sw/trng_keccak_data_auto.h /home/valeria.piscopo/TRNG/regs_gen/trng_keccak_data_regs.hjson
echo "GeneratingKeccak+TRNG block ctrl registers data SW"
/home/valeria.piscopo/TRNG/x_heep/BASE/hw/vendor/esl_epfl_x_heep/hw/vendor/pulp_platform_register_interface/vendor/lowrisc_opentitan/util/regtool.py --cdefines -o /home/valeria.piscopo/TRNG/sw/trng_keccak_ctrl_auto.h /home/valeria.piscopo/TRNG/regs_gen/trng_keccak_ctrl_regs.hjson