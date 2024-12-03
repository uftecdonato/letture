#! /bin/bash
#

source ~/rinux/funzioni/fx.sh
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Nessun colore

# versioning
my_path=$(pwd)
echo $my_path
riga_nome=1
riga_data=2
riga_vers=3
NOME=$(sed "${riga_nome}q;d" $my_path/logs/config.txt)
DATA=$(sed "${riga_data}q;d" $my_path/logs/config.txt)
VERSIONE=$(sed "${riga_vers}q;d" $my_path/logs/config.txt)
oggi=$(date +%Y-%m-%d)

# modalità
modal="." 
if [ "$modal" = "demo" ]; then
	md="(versione demo)"
else
	md="(ins. dati)"
fi
clear
echo "*************************************"
echo -e "$NOME v$VERSIONE - $oggi $md"
echo "*************************************"
#echo $my_path #test
# scelta misura
#
echo -e "quale misura vuoi inviare:"
echo -e "gasolio (gl)?\ngas (gs)?"
read ms
echo "*************************************"

if [ "$ms" = "gl" ]; then
	echo -e "Invia le letture gasolio a GitHub"
else
	echo -e "Invia le letture gas a GitHub"
fi
#

echo "*************************************"

# scelta edificio
#
echo -e "quale edificio:"
if [ "$ms" = "gl" ]; then
	echo -e "municipio (mn)?"
	misura="gasolio"
else
	echo -e "società (so)?"
	misura="gas"
fi
echo -e "san pietro (sp)?"
read ed

if [ "$ed" = "sp"  ]; then
	edif="sanpietro"
elif [ "$ed" = "mn"  ]; then
	edif="municipio"
else
	edif="socoperaia"
fi
#

file=$modal/$misura/$edif/attuale.csv

echo "*************************************"
echo -e "precedenti letture del file\n$file"
cat $file

echo "*************************************"
echo -e "Incolla la lettura: "
read letturaraw

# estrazione dati
ltt=$(echo $letturaraw | cut -c 1-1) 
tipo_m=$(echo $letturaraw | cut -c 2-2)
tipo=${tipo_m^^}
risca_m=$(echo $letturaraw | cut -c 3-3)
risca=${risca_m^^}
gg=$(echo $letturaraw | cut -c 4-5)
mm=$(echo $letturaraw | cut -c 6-7)
aaaa=$(echo $letturaraw | cut -c 8-11)
p=$(echo $letturaraw | cut -c 12-12) # prima cifra lettura
data=$gg/$mm/$aaaa
if [ "$ltt" = "m"  ]; then
	letturista="Marco"
elif [ "$ltt" = "l" ]; then
	letturista="Lothus"
elif [ "$ltt" = "f"  ]; then
	letturista="Fulvio"
else
	letturista="n.a."
fi

# estrazione lettura

if [ "$ms" = "gl" ]; then
	if [ $p -eq 0 ]; then
		hhh=$(echo $letturaraw | cut -c 13-14)
	else
		hhh=$(echo $letturaraw | cut -c 12-14)
	fi
	lettura=$data,$hhh,$tipo,,$risca
else
	if [ $p -eq 0 ]; then
		hhh=$(echo $letturaraw | cut -c 13-16)
	else
		hhh=$(echo $letturaraw | cut -c 12-16)
	fi
	dec=$(echo $letturaraw | cut -c 17-19)
	lettura=$data,$hhh.$dec
fi
#echo -e "$lettura" # test

# conferma della lettura ******************

echo -e "la lettura è:\n$lettura\neffettuata da $letturista"
echo -e "da inserire nel file\n$file"

echo "*************************************"
echo -e "Confermi la lettura? (s/n)"
read ynlettura
if [ "$ynlettura" =  "s"  ]; then
        echo -e "invio la lettura al file\n\"$file\""
        echo "$lettura" >> $file
        echo -e "done!\nverifico!"
        echo "*************************************"
        cat $file
        echo "*************************************"


        echo -e "Vuoi fare il commit del file? (s/n)"
        read yn

        if [ "$yn" =  "s"  ]; then
                echo "*************************************"
                echo -e "aggiungo il file\n$file\ncon git add"
                git add $file
                echo "*************************************"
                echo -e "file aggiunto alla staging area\ndone!"
                echo "*************************************"
                echo -e "faccio il commit"
		git commit -m "$(echo -e "chore: lettura $file\n\ninserimento lettura del $data\nesegita da $letturista")"
                echo -e "done!"
                echo "*************************************"
                git log -1 --graph
                echo "*************************************"
                echo -e "procedere con git push\noppure\ngit commit --amend"
        else
                echo -e "commit non effettuato!"
        fi
else
        echo -e "lettura mon acquisita!"
fi


echo "*************************************"
echo -e "script terminato!"
echo "*************************************"
