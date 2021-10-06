# Membrane_pore_creation
This Fortran 90 code creates pore in the membrane
The input membrane is in x-y plane and the formate is vmd *.xyz
You can make any number of circular pores randomly of fixed size, that are used for creating the membrane
Apart from pore size and number, minimum pore spacing should also be provided to maintain the structural integrity of the membrane

program input file: input_CREATE_PORE.dat
Initial membrane file:  <any_name>.xyz
Output membrane with pores: NEW_<any_name>.xyz
Main program file: create_pore.f90
Example membrane file: mos2020.xyz

compile the main program file with any compiler:-
gfortran create_pore.f90 -o create_pore.out

Edit the input file: input_CREATE_PORE.dat

run program:-
./create_pore.out

Analysis output using vmd or other visualization software;-
vmd NEW_mos2020.xyz
