#!/bin/bash

# Script para generar un archivo XYZ a partir de los POSCARS

FILE=POSCARS_1

WORK_DIR=`pwd`

mkdir    $WORK_DIR/tmp

if [ -f $WORK_DIR/goodStructures ]; then 
       cp $WORK_DIR/goodStructures $WORK_DIR/tmp
fi

cp $FILE $WORK_DIR/tmp
cd       $WORK_DIR/tmp 


#Dividimos el archivo en POSCAR individuales
#awk '/EA/{x="POSCAR"++i;}{print > x;}' $FILE
csplit -ks -f POSCAR $FILE '/EA/' {1000}
for ((i=1; i<=9; i++)); do mv POSCAR0$i POSCAR$i;done

for i in {0..1000} 
do	
   if [ -f POSCAR"$i" ]; then	
         
	 #Obtenemos el numero de estructura
	 grep "EA" POSCAR"$i" | awk {'print $1'} > structure"$i" 
         sed -i .tmp -e 's/EA/ /' -e 's/$/ /' structure"$i"
         
	 if [ -f goodStructures ]; then
	 	#Obtenemos la energia
	 	grep -f structure"$i" goodStructures | awk {'print $8'} > energy"$i"
         	echo "Struture" `cat structure"$i"` "," "Energy = " `cat energy"$i"` "eV" > title"$i"

	 	#Cambiamos el titulo del POSCAR
		cp title"$i" title
		sed -i .tmp "s/.*EA.*/$(cat title)/" POSCAR"$i"
	        rm title	
	 fi
	 
         cp POSCAR"$i" POSCAR
	 atomsk POSCAR POSCAR"$i".xyz -ig -ow
         cat POSCAR"$i".xyz >> $FILE.xyz
   fi
done

cp $FILE.xyz $WORK_DIR


cd $WORK_DIR

#Borramos archivos temporales
rm -rf $WORK_DIR/tmp 



