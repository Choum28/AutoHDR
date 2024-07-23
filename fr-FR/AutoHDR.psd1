#culture="fr_FR"
ConvertFrom-StringData @'
 #main form
 #BUTTON
 main00 = Sélectionnez une action
 mainR1 = Ajouter un jeu
 mainR2 = Supprimer un jeu
 mainR3 = Désinstaller tout
 txt1 = Entrer le nom du jeu
 txtr = Choisir le jeu à supprimer
 txtexe = Entrer le nom de l'éxécutable du jeu\n (ex : game.exe ou c:\\monjeu\\game.exe)
 txtexetooltip = Si un exécutable seul est renseigné, tous les jeux ayant le même nom d'exe déclencheront l'AutoHDR. \nSi le chemin complet vers l'exe est renseigné, seul ce jeu et cet exe déclenchera l'AutoHDR.
 txt2 = Paramètre optionnel D3D Behaviors:
 txtBuff = BufferUpgradeEnable10Bit
 txtBuffTooltip = A activer si votre moniteur/TV gère une profondeur de couleurs 10bits.
 ButtonI = Installer / Mettre à jour
 ButtonR = Supprimer jeu
 ButtonU = Désinstaller tout
 exeend = Le nom de l'executable doit finir par '.exe'
 validexe = Saisir un nom d'exe ou le chemin complet vers un exe valide.
 ok1 = Clef registre AutoHDR
 oku = Toutes les entrées registre AutoHDR ont été supprimées.
 st1 = crée.
 st2 = mise à jour.
 st3 = supprimé.
 ko1 = Erreur lors de l'installation des clefs registre AutoHDR.
 Kofound = Aucun jeu trouvé.
 koreg = introuvable dans le registre.
 kou = Aucun jeu trouvé dans le registre.
 kodel1 = Erreur lors de la suppression de la valeur chaine D3DBehaviors.
 kodel2 = Erreur lors de la suppression de la valeur chaine Name.
 kodel3 = Erreur lors de la suppression de la clef registre AutoHdr du jeu.
 kodel4 = Erreur lors de la suppression de la clef registre Direct3D.
'@
