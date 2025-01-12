#!/bin/bash
#######################################################
# This script takes care of the TalysLib installation.
#######################################################
#
# 1. Give user freedom of chosing type of the installation. 
echo "################################################################"
echo "# Welcome to the TalysLib installation script!                 #"
echo "# Please choose your preferred TalysLib installation method:   #"
echo "# 1. With TALYS code installation.                             #"
echo "# 2. WithOUT TALYS code installation.                          #"
echo "# (In case you have already installed it)                      #"
echo "################################################################"
read choice

talyslibdir=`pwd` # Define the TalysLib directory

case $choice in
    "1")
        echo "#### Going with TALYS code installation!"
        #
        # 2. Install libzip, libsqlite and gfortran packages from apt package manager 
        # (that will do nothing if they have already been installed, no problem)
        echo 'Installing libzip-dev from apt utility.'
        sudo apt install -y libzip-dev
        echo 'Installing gfortran from apt utility.'
        sudo apt install -y gfortran
        echo 'Installing libsqlite-dev from apt utility.'
        sudo apt install -y libsqlite-dev
        echo 'Installing libsqlite-dev3 from apt utility.'
        sudo apt install -y libsqlite3-dev
        cd ..
        #
        # 1-3. Download and unpack archive with TALYS
        wget https://tendl.web.psi.ch/tendl_2019/talys/talys.tar 
        echo 'The TALYS archive has been downloaded.'
        tar -xzf talys.tar
        echo 'The TALYS archive has been uncompressed.'
        cd talys
        unalias -a # Note: The unalias utility shall remove the definition 
        #           for each alias name specified
        #
        # 1-4. Define Fortran compiler for TALYS
        compiler='gfortran'       
        #compiler='lf95 --staticlink' 
        Thome=${HOME}
        cd ..
        talysdir=`pwd` # Define the TALYS directory
        #
        # 1-5. Ensure that all directories have execute permission and that 
        #    all files have a read and write permission   
        chmod -R u+rwX talys
        #
        # 1-6. Ensure that TALYS can read the structure database by replacing
        #    the path name in subroutine machine.f
        datapath=${talysdir}'/'
        datapathnew=`echo $datapath | sed 's/\//\\\\\//g'`
        cd ${talysdir}'/talys/source/'
        sed "s/ home='.*'/ home='${datapathnew}'/" machine.f  > machine_tmp.f
        mv -f machine_tmp.f machine.f
        # 
        # 1-7. Compile TALYS
        #    Please note that the compilation of ecis06t.f
        #    may result in some trivial warning messages
        ${compiler} -c *.f
        ${compiler} *.o -o talys
        #
        # 1-8. Check whether TALYS setup procedure has been successful
        if [ -e talys ] 
        then
          mv -f talys ../talys
          cd ../
          echo ' '
          echo 'The TALYS setup has been completed.'
          echo ' '
          echo 'You will find a talys executable in your' `pwd` 'directory.'
          echo ' '
          echo 'You are all set to run the sample problems in the samples directory'
          echo 'with the verify script.'
          echo 'export TALYSDIR='`pwd`>>~/.bashrc 
          echo 'export PATH=$PATH:'`pwd`>>~/.bashrc
          mkdir CalculationResults # Create directory for TalysLib calculation results
          cd ..
          rm talys.tar # Delete used TALYS archive
        else
          echo 'Error: TALYS setup failed'
        fi
    ;;
    "2")
        echo "#### Going withOUT TALYS code installation!"
        #
        # 2. Install libzip, libsqlite and gfortran packages from apt package manager 
        # (that will do nothing if they have already been installed, no problem)
        echo 'Installing libzip-dev from apt utility.'
        sudo apt install -y libzip-dev
        echo 'Installing gfortran from apt utility.'
        sudo apt install -y gfortran
        echo 'Installing libsqlite-dev from apt utility.'
        sudo apt install -y libsqlite-dev
        echo 'Installing libsqlite-dev3 from apt utility.'
        sudo apt install -y libsqlite3-dev
        #
        # 2-3. Check whether TALYS directory is set in .bashrc, go there
        if [ -z ${TALYSDIR+x} ];
        then
          echo 'Error: TALYSDIR vairable is NOT defined in .bashrc! Define it!'
          echo 'Aborting installation.'
          exit
        else
          echo 'TALYSDIR vairable is defined in .bashrc! Proceeding.'
          cd ${TALYSDIR} # Go to TALYS directory
        fi
        #
        # 2-4. Check whether TALYS has been installed
        if [ -e talys ] 
        then
          echo 'TALYS instalation is confirmed! Proceeding.'
          mkdir CalculationResults # Create directory for TalysLib calculation results
        else
          echo 'Error: TALYS instalation is NOT confirmed! Check your TALYSDIR vairable!'
          echo 'Aborting installation.'
          exit
        fi
    ;;
    "Quit"|"q"|"Q")
            echo "Quitting installation..."
        exit
    ;;
    *)
        echo "Invalid choice. Please enter either 1 or 2, or 'q' to quit."
    ;;
esac
#
# 4. Return to your TalysLib directory
cd ${talyslibdir}
#
# 5. Downloading and installing side libraries
./MakeLibraries.sh
make install


