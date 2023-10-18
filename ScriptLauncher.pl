#!/usr/bin/env perl

use POSIX qw(strftime);
use MIME::Base64;
use Cwd;

# Extraction de l'argument -h s'il est présent
if (defined $ARGV[0]) {
    $fastOption = $ARGV[0];
    shift @ARGV;
}

my $script = 0;
while ($script == 0) {

	$USER = $ENV{USER};

	my $DIR = getcwd;

	my $DEFAULTCOLOR = "\e[0m";
	my $RED = "\e[31m";
	my $GREEN = "\e[32m";
	my $YELLOW = "\e[33m";
	my $BLUE = "\e[34m";
	my $MAGENTA = "\e[35m";

	#--------------------------------------------- VERSION
	my $VERSION = "1";
	#--------------------------------------------- VERSION

	### VARIABLE UTILES :

	# $DIR -> Dossier courant
	# $configCheck -> Dossier de configuration du script
	# $slPATH -> Emplacement du dossier Script Launcher
	# $configpwdsql -> Mot de passe SQL
	# $checkupdatestate -> checkupdate status

	### CONFIG SL FILE ###

	# Ligne 1 : Chemin vers scriptlauncher/
	# Ligne 2 : checkupdatetrue | checkupdatefalse // Permet d'activer ou non le check des updates sur le repo distant.
	# Ligne 3 : Mot de passe SQL en Base64

	system("clear");
    system("echo '$BLUE ######################################################################$DEFAULTCOLOR '");
    system("echo '\t\t\t == $YELLOW SCRIPT LAUNCHER$DEFAULTCOLOR  =='");
    system("echo '$BLUE ######################################################################$DEFAULTCOLOR \n'");
    system("echo ' Utilisateur : ".$USER."'");

	### RECUPERATION DU FICHIER DE CONFIG ###

	$configCheck = '/home/'.$USER.'/Documents/SL/slconfig.txt';
	if (-e $configCheck) {

        system("echo '$GREEN Fichier de configuration trouvé :'");
        system("echo ' ".$configCheck."'");

	    open(PATHCHECK, $configCheck) || die ("$RED Erreur de lecture du fichier de configuration.$DEFAULTCOLOR ") ;

	    $count = 1;

    	$slPATH = null;
		$configpwdsql = null;
		$endOfCheck = null;

		while (my $configline = <PATHCHECK>) {
			chomp($configline);

			if ($count == 3) {
		    	$checkupdatestate = $configline;
	    		chomp($checkupdatestate);
                if ($checkupdatestate eq "checkupdatetrue") {
                    print("$GREEN . ");
                } else {
                    print("$YELLOW . ");
                }
		    } else {
				if ($count == 1) {
			    	$slPATH = $configline;
			    	if (-d $slPATH) {
			    		$slPATH = $configline;
		    		} else {
		    			$configline = null;
		    		}
			    } elsif ($count == 2) {
			    	$configpwdsql = decode_base64($configline);
		    		chomp($configpwdsql);
			    } else {
			    	$endOfCheck = 1;
			    	last;
			    }

		    	$globalCheck = $configline;

                if ($endOfCheck eq null) {
                    if ($globalCheck eq "null") {
                        print("$RED . ");
                    } else {
                        print("$BLUE . ");
                    }
                }
			}
		    $count = $count + 1;
		}

    	print("$BLUE");
		close PATHCHECK;

	} else {
	    system("echo '\n$RED Fichier de configuration non trouvé ...'");
	    system("echo '$YELLOW Démarrage de la configuraton :'");

	    sleep(1);

	    system("sudo mkdir /home/$USER/Documents/SL");
	    sleep(1);
	    system("sudo chmod -R 777 /home/$USER/Documents/SL");
	    system("sudo chown -R $USER:$USER /home/$USER/Documents/SL");
	    chdir("/home/$USER/Documents/SL");
	    system("touch ./slconfig.txt");
	    sleep(1);

	    system("echo '\n$DEFAULTCOLOR Saisissez le chemin vers votre dossier $GREEN Script Launcher$DEFAULTCOLOR  : '");
	    system("echo '$YELLOW (Le chemin à saisir doit commencer par $GREEN/var/$DEFAULTCOLOR... ou $GREEN/home/$DEFAULTCOLOR... ne pas renseigner de $RED~$DEFAULTCOLOR)'");

	    my $configSLPATH = <>;
	    chomp($configSLPATH);

	    if (-d $configSLPATH){
		    system("echo \'$GREEN-> Le dossier existe ! Mise à jour du fichier de config...\'");
	    	system("sudo echo '".$configSLPATH."' >> /home/$USER/Documents/SL/slconfig.txt");
		} else {
		    system("echo \'$RED-> Le dossier n'existe pas. Passage à l'étape suivante.\'");
		    system("sudo echo 'null' >> /home/$USER/Documents/SL/slconfig.txt");
		}

	    sleep(1);

	    system("echo '\n$DEFAULTCOLOR Voulez-vous activer la recherche de mise à jour automatique pour $GREEN SL$DEFAULTCOLOR ? $YELLOW [O/N]'");

	    my $configupdate = <>;
	    chomp($configupdate);
	    if ($configupdate eq "O") {
	    	system("sudo echo 'checkupdatetrue' >> /home/$USER/Documents/SL/slconfig.txt");
    	} else {
	    	system("sudo echo 'checkupdatefalse' >> /home/$USER/Documents/SL/slconfig.txt");
	    }

	    sleep(1);

	    system("echo '\n$DEFAULTCOLOR Saisissez votre mot de passe $GREEN SQL$DEFAULTCOLOR  : $YELLOW [facultatif]'");
		system("echo '$YELLOW (Le mot de passe sera enregistré dans le fichier de config en base64)'");

	    my $configpwdsql = <>;
	    chomp($configpwdsql);
	    if ($configpwdsql eq '') {
	    	system("sudo echo 'null' >> /home/$USER/Documents/SL/slconfig.txt");
	    } else {
	    	 system("sudo echo '".$configpwdsql."' | base64 >> /home/$USER/Documents/SL/slconfig.txt");
	    }

	    sleep(1);

	    system("echo '$GREEN Configuration terminée. Redémarrage.'");
	    sleep(1);
	    system("clear");
	    system("sl");
	}

    system("echo '\n\n --------------------------------------------------'");
    printf("$YELLOW V - $VERSION $DEFAULTCOLOR");
    if ($checkupdatestate eq "checkupdatetrue") {
        chdir($slPATH);
        branch_status();
        system("echo '$BLUE --------------------------------------------------'");
    } else {
        print "$DEFAULTCOLOR->$YELLOW UPDATE CHECK DISABLED\n";
        system("echo '$BLUE --------------------------------------------------'");
    }

	####################################################################################################
	####################################################################################################
	# CUSTOM MENU
	####################################################################################################
	####################################################################################################

    system("echo '\n$MAGENTA ##########$DEFAULTCOLOR  STRUCTURE $DEFAULTCOLOR \n'");
    if ($slPATH eq null){print "$RED X";}system("echo '\t$MAGENTA # 1$DEFAULTCOLOR   - INSTALLATION / MISE A JOUR SCRIPT LAUNCHER'");
    system("echo '\n$MAGENTA ##########$DEFAULTCOLOR  DEVELOPPEMENT $DEFAULTCOLOR \n'");
    system("echo '\t$MAGENTA # 2$DEFAULTCOLOR  - CONNEXION MYSQL'");
    system("echo '\n$MAGENTA ##########$DEFAULTCOLOR  DIVERS $DEFAULTCOLOR \n'");
    system("echo '\t$MAGENTA # 3$DEFAULTCOLOR  - SOUS MENU'");
    system("echo '\t$MAGENTA # 4$DEFAULTCOLOR  - CONFIGURATION SCRIPT LAUNCHER (VIM)'");
    system("echo '\t$MAGENTA # 5$DEFAULTCOLOR  - VIDER LA CORBEILLE'");

    system("echo '\n$BLUE ######################################################################$DEFAULTCOLOR \n'");

    printf("$GREEN -> $DEFAULTCOLOR Option : ");

    if ($fastOption eq '') {
	    $choice = <>;
	} else {
		$choice = $fastOption;
		printf($fastOption."\n");
	}

    system("echo '$DEFAULTCOLOR --------------------------------------------------\n'");

	####################################################################################################
	####################################################################################################
	# 1 - INSTALLATION / MISE A JOUR SCRIPT LAUNCHER
	####################################################################################################
	####################################################################################################

	if ($choice == 1) {
		if ($slPATH eq null){system("echo '$RED Impossible de lancer ce processus.$DEFAULTCOLOR '");exit;}

		printf("$GREEN -> $YELLOW 1$DEFAULTCOLOR - Nouvelle Installation | $YELLOW 2$DEFAULTCOLOR - Mise à Jour  : ");
		my $setupChoice = <>;

		if ($setupChoice == 2) {

			chdir($slPATH);

			system("echo '$GREEN ->$DEFAULTCOLOR  Attribution des $YELLOW permissions$DEFAULTCOLOR .'");
			system("sudo chown -R $USER:33 .git");
			system("sudo chmod -R 775 .git");

			sleep(1);

			system("echo '$GREEN ->$DEFAULTCOLOR  lancement de la commande $YELLOW git pull$DEFAULTCOLOR  dans le dossier SCRIPT LAUNCHER.'");
			system("git pull");
			system("echo '\n_____\n'");
			system("echo '$GREEN OK$DEFAULTCOLOR '");
			system("echo '_____\n'");

			sleep(1);

			system("echo '$GREEN ->$DEFAULTCOLOR  Suppression & Copie de $YELLOW SL$DEFAULTCOLOR  vers /usr/local/bin/sl.'");
			system("sudo rm -rf /usr/local/bin/sl");
			system("sudo cp ./sl /usr/local/bin/sl");
			system("echo '\n_____\n'");
			system("echo '$GREEN OK$DEFAULTCOLOR '");
			system("echo '_____\n'");

			sleep(1);
		} else {

			system("echo '$GREEN ->$DEFAULTCOLOR Suppression de l ancienne version de SL :$DEFAULTCOLOR'");
			system("echo '_____\n'");
			system("sudo rm -rf /usr/local/bin/sl");
			system("echo '\n_____\n'");
			system("echo '$GREEN OK$DEFAULTCOLOR'");
			system("echo '_____\n'");

			sleep(1);

			system("echo '$GREEN ->$DEFAULTCOLOR Suppression des fichiers de configurations SL :$DEFAULTCOLOR'");
			system("echo '_____\n'");
			system("sudo rm -rf ~/Documents/SL");
			system("echo '\n_____\n'");
			system("echo '$GREEN OK$DEFAULTCOLOR'");
			system("echo '_____\n'");

			sleep(1);

			system("echo '$GREEN ->$DEFAULTCOLOR Copie du script SLUG dans le dossier /usr/local/bin/ :$DEFAULTCOLOR'");
			system("echo '_____\n'");
			system("sudo cp ./plugins/slug /usr/local/bin/");
			system("echo '\n_____\n'");
			system("echo '$GREEN OK$DEFAULTCOLOR'");
			system("echo '_____\n'");

			sleep(1);

			system("echo '$GREEN ->$DEFAULTCOLOR Copie du script SL dans le dossier /usr/local/bin/ :$DEFAULTCOLOR'");
			system("echo '_____\n'");
			system("sudo cp ./sl /usr/local/bin/");
			system("echo '\n_____\n'");
			system("echo '$GREEN OK$DEFAULTCOLOR'");
			system("echo '_____\n'");

			sleep(1);

			system("echo '$GREEN->$DEFAULTCOLOR Attribution des droits :$DEFAULTCOLOR'");
			system("echo '_____\n'");
			system("sudo chmod 777 /usr/local/bin/sl");
			system("echo '\n_____\n'");
			system("echo '$GREEN OK$DEFAULTCOLOR'");
			system("echo '_____\n'");

			sleep(1);
		}
	}

	####################################################################################################
	####################################################################################################
	# 2 - CONNEXION MYSQL
	####################################################################################################
	####################################################################################################

	elsif ($choice == 2) {
		if ($configpwdsql eq null) {
			system("mysql -u user -p -h 127.0.0.1");
		} else {
			system("mysql -u user -p".$configpwdsql." -h 127.0.0.1");
		}
		sleep(1);
	}

####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################

	####################################################################################################
	####################################################################################################
	# 3 - SOUS MENU
	####################################################################################################
	####################################################################################################

	elsif ($choice == 3) {
		system("clear");
		system("echo '$BLUE ######################################################################$DEFAULTCOLOR '");
		system("echo '\t\t\t == $YELLOW SCRIPT LAUNCHER$DEFAULTCOLOR  =='");
		system("echo '$BLUE ######################################################################$DEFAULTCOLOR \n'");

	    system("echo '\t$YELLOW SOUS MENU :$DEFAULTCOLOR '");

		####################################################################################################
		####################################################################################################
		# CUSTOM SOUS MENU
		####################################################################################################
		####################################################################################################

		system("echo '\n$MAGENTA ##########$DEFAULTCOLOR  SECTION 1 $DEFAULTCOLOR \n'");
		system("echo '\t$MAGENTA # 1$DEFAULTCOLOR  - SCRIPT 1'");
		system("echo '\n$MAGENTA ##########$DEFAULTCOLOR  RETOUR $DEFAULTCOLOR \n'");
		system("echo '\t$RED # AUTRE - QUITTER$DEFAULTCOLOR '");

		system("echo '\n$BLUE ######################################################################$DEFAULTCOLOR \n'");

		printf("$GREEN -> $DEFAULTCOLOR Option : ");
		my $choicesubmenu = <>;

		system("echo '$DEFAULTCOLOR --------------------------------------------------\n'");

		####################################################################################################
		####################################################################################################
		# 3.1 - CHOIX 1
		####################################################################################################
		####################################################################################################

		if ($choicesubmenu == 1) {

		}
	}

####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################

	####################################################################################################
	####################################################################################################
	# 4 - CONFIGURATION SCRIPT LAUNCHER
	####################################################################################################
	####################################################################################################

	elsif ($choice == 4) {
		system("sudo vim $configCheck");
	}

	####################################################################################################
	####################################################################################################
	# 5 - VIDER LA CORBEILLE
	####################################################################################################
	####################################################################################################

	elsif ($choice == 5) {
		system("echo '$GREEN ->$DEFAULTCOLOR  lancement de la commande : $YELLOW sudo rm -rf ~/.local/share/Trash/files/*$DEFAULTCOLOR '");
		system("sudo rm -rf ~/.local/share/Trash/files/*");
		system("echo '\n_____\n'");
		system("echo '$GREEN OK$DEFAULTCOLOR '");
		
		sleep(1);
	}

	####################################################################################################
	####################################################################################################
	# 0 - EXIT
	####################################################################################################
	####################################################################################################

	else {
		system("clear");
		exit;
	}

    system("echo '\n$BLUE ######################################################################'$DEFAULTCOLOR ");
    system("echo '\t\t\t == $YELLOW Terminé !$DEFAULTCOLOR  =='");
    system("echo '$BLUE ######################################################################$DEFAULTCOLOR \n'");
    
    $fastOption = '';

	sleep(1);

	system("echo '--- $YELLOW Appuyer sur ENTREE pour continuer$DEFAULTCOLOR  ---'");
	my $continue = <>;

####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################

	####################################################################################################
	####################################################################################################
	# FUNCTIONS
	####################################################################################################
	####################################################################################################

	sub checkFormat {
		($valueToCheck) = @_;
	   	if (substr($valueToCheck, 0, 1) eq '"' && substr($valueToCheck, -1) eq '"') {}
		else {
			system("echo '$RED=> Erreur de format.$YELLOW Tentative restante (1) $DEFAULTCOLOR:'");

			my $value = <STDIN>;
			chomp($value);

			if (substr($value, 0, 1) eq '"' && substr($value, -1) eq '"') {
				$valueToCheck = $value;
			} else {
				system("echo '$RED=> Arrêt du processus : Erreur de format. $DEFAULTCOLOR'");
				exit;
			}
		}
		return $valueToCheck;
	}

	sub checkIsNull {
		($valueToCheck) = @_;
	   	if ($valueToCheck eq "") {
			system("echo '$RED=>Cette valeur ne peut-être NULL$YELLOW Tentative restante (1) $DEFAULTCOLOR:'");

			my $value = <STDIN>;
			chomp($value);

			if ($value eq "") {
				system("echo '$RED=> Arrêt du processus : Erreur de format. $DEFAULTCOLOR'");
				exit;
			} else {
				$valueToCheck = $value;
			}
		}
		return $valueToCheck;
	}

	sub branch_status {
		my $remote = `git ls-remote --heads origin master 2> /dev/null`;
		my $local = `git show-ref --heads master 2> /dev/null`;

		($remote, $local) = removeSpacesBetweenTwoStr($remote, $local);

		if ($remote eq $local) {
			print " $DEFAULTCOLOR->$GREEN VERSION A JOUR\n";
		} else {
			my $ahead = `git rev-list origin/master..master --count 2> /dev/null`;
			my $behind = `git rev-list master..origin/master --count 2> /dev/null`;
			if ($ahead > 0) {
				print " $DEFAULTCOLOR->$YELLOW VERSION EN AVANCE\n";
			} elsif ($behind > 0) {
				print " $DEFAULTCOLOR->$RED VERSION DERRIERE\n";
			} else {
				print " $DEFAULTCOLOR->$YELLOW VERSION DIVERGENTE\n";
			}
		}
	}

	sub removeSpacesBetweenTwoStr {
	    my ($str1, $str2) = @_;
	    $str1 =~ s/\s+//g;
	    $str2 =~ s/\s+//g;
	    return ($str1, $str2);
	}
}