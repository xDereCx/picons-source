#!/bin/bash

#sudo apt-get install imagemagick pngnq librsvg2-bin

version="$(date +"%Y-%m-%d--%H-%M-%S")"
timestamp=`echo ${version//-/} | rev | cut -c 3- | rev`.`echo ${version//-/} | cut -c 13-`

if [ -d "/dev/shm" ]; then
    temp="/dev/shm/picons-tmp"
else
    temp="/tmp/picons-tmp"
fi

location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
buildsource="$location/build-source"
buildtools="$location/build-tools"
binaries="$HOME/picons-binaries"
logfile="$temp/picons.log"

if [ -d "$temp" ]; then
    rm -rf "$temp"
fi
mkdir "$temp"

if [ -d "$binaries" ]; then
    rm -rf "$binaries"
fi
mkdir "$binaries"

chmod -R 755 "$buildtools"/*.sh

echo "$(date +"%H:%M:%S") - Version: $version"
echo "$version" > "$logfile"

echo "$(date +"%H:%M:%S") - Checking logos"
"$buildtools"/check-logos.sh "$buildsource/tv"
"$buildtools"/check-logos.sh "$buildsource/radio"

echo "$(date +"%H:%M:%S") - Creating symlinks and copying logos"
"$buildtools"/create-symlinks+copy-logos.sh "$HOME/servicelist_" "$temp/newbuildsource" "$buildsource"

echo "$(date +"%H:%M:%S") - Converting svg files"
for file in $(find "$temp/newbuildsource/logos" -type f -name '*.svg'); do
    rsvg-convert -w 400 -h 400 -a -f png -o ${file%.*}.png "$file"
    rm "$file"
done

for background in "$buildsource/backgrounds/"*.build ; do

    backgroundname=${background%.*}
    backgroundname=${backgroundname##*/}

    for backgroundcolor in "$buildsource/backgrounds/$backgroundname.build/"*.build ; do

        backgroundcolorname=${backgroundcolor%.*}
        backgroundcolorname=${backgroundcolorname%.*}
        backgroundcolorname=${backgroundcolorname##*/}

        echo "$(date +"%H:%M:%S") -----------------------------------------------------------"
        echo "$(date +"%H:%M:%S") - Creating picons: $backgroundname.$backgroundcolorname"

        mkdir -p "$temp/finalpicons/picon"

        for directory in "$temp/newbuildsource/logos/"* ; do
            if [ -d "$directory" ]; then
                directory=${directory##*/}
                for logo in "$temp/newbuildsource/logos/$directory/"*.png ; do
                    if [ -f "$logo" ]; then
                        logoname=${logo##*/}
                        logoname=${logoname%.*}
                        fullfilepath="$temp/finalpicons/picon/$directory/$logoname.png"

                        if ! [ -d "$temp/finalpicons/picon/$directory" ]; then
                            mkdir -p "$temp/finalpicons/picon/$directory"
                        fi

                        if [[ "$backgroundcolorname" == *-white* ]]; then
                            if [ -f "$temp/newbuildsource/logos/$directory/white/$logoname.png" ]; then
                                logo="$temp/newbuildsource/logos/$directory/white/$logoname.png"
                            fi
                        fi

                        case "$backgroundname" in
                            "70x53")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="70x53"; else resize="62x45"; fi
                                extent="70x53"
                                compress="pngnq -g 2.2 -s 1"
                                ;;
                            "100x60")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="100x60"; else resize="86x46"; fi
                                extent="100x60"
                                compress="pngnq -g 2.2 -s 1"
                                ;;
                            "220x132")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="220x132"; else resize="189x101"; fi
                                extent="220x132"
                                compress="pngnq -g 2.2 -s 1"
                                ;;
                            "400x240")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="400x240"; else resize="369x221"; fi
                                extent="400x240"
                                compress="pngnq -g 2.2 -s 1"
                                ;;
                            "kodi")
                                if [[ "$backgroundcolorname" == *-nopadding ]]; then resize="256x256"; else resize="226x226"; fi
                                extent="256x256"
                                compress="cat"
                                ;;
                        esac

                        convert "$backgroundcolor" \( "$logo" -background none -bordercolor none -border 100 -trim -resize $resize -gravity center -extent $extent +repage \) -layers merge - 2>> "$logfile" | $compress > "$fullfilepath" 2>> "$logfile"
                    fi
                done
            fi
        done

        echo "$(date +"%H:%M:%S") - Copying symlinks: $backgroundname.$backgroundcolorname"
        cp --no-dereference "$temp/newbuildsource/symlinks/"* "$temp/finalpicons/picon" 2>> "$logfile"

        if [ "$backgroundname" = "70x53" ] || [ "$backgroundname" = "100x60" ] || [ "$backgroundname" = "220x132" ] || [ "$backgroundname" = "400x240" ]; then

            echo "$(date +"%H:%M:%S") - Creating ipk: $backgroundname.$backgroundcolorname"
            echo "2.0" > "$temp/finalpicons/debian-binary"
            mkdir "$temp/finalpicons/DEBIAN"
            echo "Package: enigma2-plugin-picons-tv-$backgroundname.$backgroundcolorname" > "$temp/finalpicons/DEBIAN/control"
            echo "Version: $version" >> "$temp/finalpicons/DEBIAN/control"
            echo "Section: base" >> "$temp/finalpicons/DEBIAN/control"
            echo "Architecture: all" >> "$temp/finalpicons/DEBIAN/control"
            echo "Maintainer: http://picons.github.io" >> "$temp/finalpicons/DEBIAN/control"
            echo "Source: https://github.com/picons/picons-source" >> "$temp/finalpicons/DEBIAN/control"
            echo "Description: $backgroundname Picons ($backgroundcolorname)" >> "$temp/finalpicons/DEBIAN/control"
            echo "OE: enigma2-plugin-picons-tv-$backgroundname.$backgroundcolorname" >> "$temp/finalpicons/DEBIAN/control"
            echo "HomePage: http://picons.github.io" >> "$temp/finalpicons/DEBIAN/control"
            echo "License: unknown" >> "$temp/finalpicons/DEBIAN/control"
            echo "Priority: optional" >> "$temp/finalpicons/DEBIAN/control"
            fakeroot -- dpkg-deb -z9 -Zxz -Sextreme --build "$temp/finalpicons" "$binaries/enigma2-plugin-picons-tv-$backgroundname.$backgroundcolorname"\_"$version.ipk" &>> "$logfile"

        fi

        echo "$(date +"%H:%M:%S") - Creating tar.xz: $backgroundname.$backgroundcolorname"
        mv "$temp/finalpicons/picon" "$temp/finalpicons/$backgroundname.$backgroundcolorname"\_"$version" 2>> "$logfile"
        #HARD LINK
        XZ_OPT=-9e tar --dereference --owner=root --group=root -cJf "$binaries/$backgroundname.$backgroundcolorname"\_"$version.tar.xz" -C "$temp/finalpicons" "$backgroundname.$backgroundcolorname"\_"$version" --exclude="tv" --exclude="radio"
        #SYMBOLIC LINK
        #XZ_OPT=-9e tar --owner=root --group=root -cJf "$binaries/$backgroundname.$backgroundcolorname"\_"$version.tar.xz" -C "$temp/finalpicons" "$backgroundname.$backgroundcolorname"\_"$version"
        #NO LINK
        #XZ_OPT=-9e tar --hard-dereference --dereference --owner=root --group=root -cJf "$binaries/$backgroundname.$backgroundcolorname"\_"$version.tar.xz" -C "$temp/finalpicons" "$backgroundname.$backgroundcolorname"\_"$version" --exclude="tv" --exclude="radio"

        rm -rf "$temp/finalpicons"

    done

done

for file in "$binaries/"* ; do
    touch -t "$timestamp" "$file"
done

if [ -d "$temp" ]; then
    rm -rf "$temp"
fi

read -p "Press any key to exit..." -n1 -s
