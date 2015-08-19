#!/usr/bin/perl
#File: BE

#@title: Conversion.pl
#@Description: This file finds any discrepancies (or lack thereof) between two files:
#A given source directory and a SetOwnerPath
#used in the obsolete Clearcase SCM used for projects
#in the BuildWizard.NET continuous integration client
#@Author: Paul Ryan Olivar
#@Date: June 2015
#@Arguments:
# - sourceDirectory - Root path from which file search will start
# -setOwnerPath - Path of the table to compare

#Source Directory test: websuite_3rdparty\BE\DMS BE Release
#setOwner Directory test: websuite_3rdparty\BE\install\SETOWNER.TBL
#Execution test: perl "TBLcheck.pl websuite_3rdparty\BE\DMS BE Release" "websuite_3rdparty\BE\install\SETOWNER.TBL"
#Paul Ryan Olivar lf
#Set CONSTANTS
use constant{
TRUE => 0,
EXIT_SUCCESS => 0,
FALSE => 1,
EXIT_FAILURE => 1,
};

#Get number of arguments
my $numArgs = scalar(@ARGV);

#Get script arguments
$setOwnerPath = $ARGV[0];
$sourceDirectory = $ARGV[1];
$targetPrefix = $ARGV[2];
my @extraArgs=();

#If there are extra arguments, add them to the array for extra arguments
if($numArgs > 3){
	print("There are more than three arguments \n");
	for(my $excessArgIndex = 3; $excessArgIndex < $numArgs; $excessArgIndex++){

		print "Checking if $sourceDirectory/$ARGV[$excessArgIndex] exists \n";
		checkExists("$sourceDirectory/$ARGV[$excessArgIndex]");
		push(@extraArgs,$ARGV[$excessArgIndex]);

} 


}


$filetree = "$sourceDirectory/$targetPrefix";

#Check if directories exist
checkExists($sourceDirectory);
checkExists($setOwnerPath);
checkExists($filetree);

print "the file tree to search is $filetree";

system("echo 'Doing a find on $filetree'");

#system("stat -f "%n %a %U %G" ");
system("find '$filetree' > files.txt");

#If there are extra arguments, add them to files.txt
if (scalar(@extraArgs) > 0){

for(my $index; $index<scalar(@extraArgs); $index++){

system("find $sourceDirectory/@extraArgs[$index] >> files.txt");

}

}


$file = "files.txt";

#Open the text file that contains all file names in the path and store it in the @lines array
my @lines = openFile($file);

#Trim off sourceDirectory string from filenames
foreach $rawLine (@lines){
$rawLine =~ s/$sourceDirectory\///g;
}

$size = scalar(@lines);
print "The size of lines is $size";

#Get path of setOwner.tbl file
$tableFile = $setOwnerPath;

#Open the SETOWNER.TBL file and store lines in the @tableRows array
my @tableRows = openFile($tableFile);

#Trim off leading slashes from files in table
foreach $tableLine (@tableRows){
#if first character is a /, remove it
$tableLine =~ s/^\///;

}

$numRows = scalar(@tableRows);
print "The size of tableRows is $numRows";

#Create boolean variable that determines if all files are found
#true = 0, false = 1
#false by default (for safety reasons)
my $PhaseOnematches = FALSE;

#Initialize empty array to store missing files
my @missingFiles = ();

#PHASE 1:
#Check if everyone in files.txt is in SETOWNER.TBL
#Execute Phase One
PhaseOne();

print "\n RETURN CODE $PhaseOnematches \n";

$MFsize = scalar(@missingFiles);
print "\n THERE ARE $MFsize missing files from Phase one \n "; 

#If there were missing files in phase one, exit with error code 1
if (scalar(@missingFiles) > 0){
print "\n THERE WERE $MFSize MISSING FILES IN PHASE ONE \n";

print " The missing files were: \n";

for(my $index = 0; $index < scalar(@missingFiles); $index++){
print "@missingFiles[$index] \n";
}

exit EXIT_FAILURE;
}



#PHASE 2:
#Check if everything in SETOWNER.TBL file is in files.txt
#create variable that determines whether or not everything in SETOWNER.TBL was found in files.txt
my $phaseTwoMatches = FALSE;

#Execute Phase 2
PhaseTwo();

#Get size of missing files array
$MFsize = scalar(@missingFiles);

#If there are missing files, exit with error code 1, else return exit success
if (scalar(@missingFiles) > 0){
print "\n THERE WERE $MFsize MISSING FILES IN PHASE 2";
print "\n The missing file is @missingFiles[0] \n";
exit EXIT_FAILURE;
}
else{
print "\n Phase 1 and Phase 2 complete. All files in $filetree match the files in $setOwnerPath \n";
exit EXIT_SUCCESS;
}


#Subroutines

#@Subroutine name: checkExists
#@params: 
# -$directory: A string that contains a file/directory path
#@Description: Checks if file exists in given path
sub checkExists{

	my $Directory = @_[0];

	if(-e "$Directory"){

	print "$Directory exists \n";

	}
	else{
	print "$Directory does not exist. \n";
	exit EXIT_FAILURE;
	}

}



#Subroutine name: openFile
#@params:
# -$fileName: A string that contains the name of the file to be opened
#@Description: Opens a file of the given name
sub openFile{

	#Get argument
	my $fileName = @_[0];

	#open file
	open(INFO, $fileName) or FileOpenFailure($fileName);
	#@lines = <INFO>;
 
 	#Remove newline characters
	chomp(@lines);
 
	return <INFO>;

}

#Subroutine name: PhaseOne
#@params: none
#@Description: Checks if files in files.txt are in SETOWNER.TBL
sub PhaseOne{

print "\n Searching through array lines @lines \n";

#PHASE 1:
#Check if everyone in files.txt is in SETOWNER.TBL
	for(my $index = 0; $index < $size; $index++){

		#Get current line of files.txt
		$line = $lines[$index];
		#print "\n The current line is |$lines[$index]| \n";
		#In addition to pathname, get owner, group, and permissions for the given filename
		#$lineFormat = `stat -c "%n %U %G %a" "$line"`;
		
		$lineFormat = $line;
		
		#remove newLine characters from lineFormat
		chomp($lineFormat);
		
		
		
		#reset PhaseOnematches to default false
		$PhaseOnematches = FALSE;

		#remove carriage return from $lineFormat
		chomp($lineFormat);
		
		#Check if the $lineFormat is in SETOWNER.tbl
		#iterate through every line of SETOWNER.tbl
		for(my $rowIndex = 0; $rowIndex < $numRows; $rowIndex++){

			#Take out line endings of the current row
			chomp(@tableRows[$rowIndex]);

my $row = @tableRows[$rowIndex];

my $rowFile = substr $row, 0, index($row,' ');
			
			print "\n Comparing |$lineFormat| to |$rowFile| \n";
			#if file is found in SETOWNER.tbl, set boolean to true and break out of loop
			if ("$lineFormat" eq "$rowFile"){
				print "\n! $lineFormat MATCHES $rowFile !\n";
				$PhaseOnematches = TRUE;
				last;
				}
				else{
				$phaseOneMatches = FALSE;
				
				}

		}

	#If current file is not found in SETOWNER.TBL, Add it to the array of files that are missing
	if ($PhaseOnematches == FALSE){
	push(@missingFiles, $line);
	}
	

	}

}



#@Subroutine name: PhaseTwo
#@params: none
#@Description: Checks if files in SETOWNER.TBL are in files.txt
sub PhaseTwo{
	#iterate through every line in SETOWNER.TBL
	for (my $rowIndex = 0; $rowIndex < $numRows; $rowIndex++){


	#Take out all line endings of current row
	chomp(@tableRows[$rowIndex]);

my $row = @tableRows[$rowIndex];

my $rowFile = substr $row, 0, index($row,' ');

		#Iterate through files.txt to find row
		for(my $index = 0; $index < $size; $index++){

		#Get filename
		$line = $lines[$index];

		#In addition to pathname, get owner, group, and permissions for the given filename
		$lineFormat = $line;

		#Take out all line endings
		chomp($lineFormat);


		#if file is found in files.txt, set boolean to true and break out of the loop
		if ("$rowFile" eq "$lineFormat"){
		print "\n!  |$rowFile| MATCHES |$lineFormat|!\n";
		$phaseTwoMatches = TRUE;
		last;
		}
		else{
		$phaseTwoMatches = FALSE;
		}

		}

	#If current file is not found in files.txt, Add it to the array of files that are missing 
	if($phaseTwoMatches == FALSE){
	push(@missingFiles, @tableRows[$rowIndex]);
	}



	}
}


#@Subroutine name: FileOpenFailure
#@params: 
# -Filename: The name of the file that failed to open
#@Description: Checks if files in SETOWNER.TBL are in files.txt
sub FileOpenFailure{
	my $fileName = @_[0];
	print "Could not open $fileName.";
	exit EXIT_FAILURE;
}



