#!/bin/bash
#
if [ "$DECHOICE" = "kaidaplasma" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "fullplasma" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "minimalplasma" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "gnome" ]; then

      systemctl enable gdm

   elif [ "$DECHOICE" = "fullgnome" ]; then

      systemctl enable gdm
      
   elif [ "$DECHOICE" = "xfce" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "fullxfce" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "MATE" ]; then

      systemctl enable sddm
      
   elif [ "$DECHOICE" = "fullMATE" ]; then

      systemctl enable sddm
      
   elif [ "$DECHOICE" = "cinnamon" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "deepin" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "fulldeepin" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "lxqt" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "i3gaps" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "xmonad" ]; then

      systemctl enable sddm

   elif [ "$DECHOICE" = "openbox" ]; then

      systemctl enable sddm
   else

      echo -ne "no Gui was choosen"

fi
