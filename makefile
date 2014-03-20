# This makefile is to be invoked as 'doc ...', where doc is aliased, eg,
#
#      % alias doc 'make D=`pwd` -f ~/wr/docutils/makefile'
#
# Set up a "Config" file in a directory set aside to hold the spec you are
# editing and its associated files; its own directory is useful because
# your spec generates a handful of auxiliary files for each spec version.
# The Config file defines
#
#    A=<one word primary editor/author surname>
#    S=<one word doc name>
#    V=<i-d version number>
#    U=<other version number>     (not used yet)
#
# Edit all changes in the file $S.xml then run "doc".  Example Config file:
#
#    # Increment V=... when snapshotting a version.
#    A=kunze
#    V=10
#    S=bagit
#    U=0.97
#
# Run "doc snapshot" to freeze a specific version and start work on
# a newly incremented V=version (branch); this has you edit V in Config
# and increment it by hand, and when you exit the previous version's
# files are safely isolated from writing by any further invocation.

BASE=~/wr/docutils
#X2R=$(BASE)/xml2rfc-1.32/xml2rfc.tcl
#X2R=$(BASE)/xml2rfc-1.34pre3/xml2rfc.tcl
#X2R=$(BASE)/xml2rfc-1.35/xml2rfc.tcl
X2R=$(BASE)/xml2rfc-1.36/xml2rfc.tcl
WEBDIR=http://dot.ucop.edu/specs
WDIR=~/w/specs
EDITOR=vi

# a '-' in front of "include" ignores if not present; remedial action of
-include Config

default: config_check usage

# xxx to do: 'format' breaks into 'format' and 'webify'
# xxx        'dist' breaks into 'dist' (hg) and 'publicize'
usage:
	@echo "For $A, doc $S, Version $V ($U):"
	@echo "Type 'doc format' to create HTML formatted spec."
	@echo "Type 'doc diff' to diff 'old.txt' with current."
	@echo "Type 'doc dist' to update 'inside CDL'."
	@echo "Type 'doc text' to create TXT formatted spec (made by 'diff')."
	@echo "Type 'doc ietf' to create IETF versions (special TXT and HTML)."
	@echo "Type 'doc snapshot' to increment V= and save old IETF version."
	@echo "Other forms that might be useful if better thought through:"
	@echo "   'doc review' to copy HTML to externalizable URL."
	@echo "   'doc register' to add spec to 6-month expiration registry."
	@echo "   'doc list' to show specs and expiration."

config_check:
	@if [ ! -f Config ] ; then \
		echo "You must set up Config file first; see 'doc init'." ; \
		exit 1 ; \
	 elif [ "$A" = "" -o "$S" = "" -o "$V" = "" ] ; then \
		echo "A or S or V is undefined; see 'doc init'." ; \
		exit 1 ; \
	fi

init:
	@echo "To use this tool, first create a file called 'Config' in"
	@echo "your document directory, defining at least 3 variables:"
	@echo "#  A=<one word author last name>      eg, A=smith"
	@echo "#  S=<one word document name>         eg, S=bagit"
	@echo "#  V=<internet-draft version number>  eg, V=00"
	@echo "#  U=<other version number (unused)>  eg, U=0.97"

f-$S.xml: $S.xml
	sed -e "s/\(<!ENTITY uversion  *'\).*/\1$U' >/" \
		-e "s/\(<!ENTITY vversion  *'\).*/\1$V' >/" \
			$S.xml > f-$S.xml

format: f-$S.xml
	$(X2R) $D/f-$S.xml $D/$S-$V.html
	@/bin/cp $S-$V.html $Sspec.html
	@/bin/cp $D/$Sspec.html $(WDIR)
	@echo "Update to $(WEBDIR)/$Sspec.html"

text: f-$S.xml
	$(X2R) $D/f-$S.xml $D/$S-$V.txt
	@/bin/cp $S-$V.txt $Sspec.txt
	@/bin/cp $D/$Sspec.txt $(WDIR)
	@echo "Update to $(WEBDIR)/$Sspec.txt"

diff: text
	$(BASE)/htmlwdiff.sh $D/old.txt $D/$S-$V.txt > $S-old-$V-diffs.html
	@/bin/cp $S-old-$V-diffs.html $(WDIR)
	@echo "From 'old.txt', diffs in $(WEBDIR)/$S-old-$V-diffs.html"

review: format
	/bin/cp $D/$Sspec.html $(WDIR)
	#@echo "Did you increment the date and version number?  OK then."
	@echo "External review via $(WEBDIR)/$Sspec.html"

register: f-$S.xml
	@echo `date '+%Y.%m.%d'` $S-$V : \
		"`sed -n 's/.*<title> *\([^<]*\)<.*/\1/p' $S-$V.html`" \
		>> $(BASE)/registry

list:
	sort -r $(BASE)/registry | sed 's/: [^:]*: /: /'

snapshot: f-$S.xml
	$(EDITOR) Config
	/bin/cp $S.xml $S-$V.xml
	@echo "Saved source to $S-$V. You bumped up V" \
		"(version in Config) to prevent clobbering next time, right?"
	@grep -q -v "V=$V" Config && echo "No, I guess you didn't!" && exit 1
	#@grep "V=$V" Config > x && echo "No, I guess you didn't!"
	# When all goes well, make throws a stupid error. XXX
	# xxx try putting grep in () next time?

ietf: f-$S.xml
	sed -e '/<!--#if internet-draft dont/d' -e \
	 "s/<!--#if internet-draft then *\(.*\)A-S-00.txt.> -->/\1$A-$S-$V.txt\">/" \
		f-$S.xml > id-$S-$V.xml
	$(X2R) $D/id-$S-$V.xml $D/id-$S-$V.html
	$(X2R) $D/id-$S-$V.xml $D/id-$S-$V.txt
	/bin/cp id-$S-$V.html id-$Sspec.html
	/bin/cp id-$S-$V.txt id-$Sspec.txt
	/bin/cp id-$S-$V.xml id-$Sspec.xml
	/bin/cp id-$Sspec.* $(WDIR)

%.html: %.rst
	(base="$(<:.rst=)" ; title="$($(<:.rst=))" ; echo title is $${title:-Set your title in Config with $$base=My Title} \
		echo pandoc minusT "$${title:-Set your title in Config with $$base=My Title}" -s -S -c pandoc.css -o $W/$@ > $< \
		cp -p $< $W/$(<:.rst=.txt) )

# change 'jak' to your login if you're not 'jak'
stage = jak@cdlib-stage.cdlib.org
prod = jak@www.cdlib.org

dist: format
	# Create another version: TXT
	# XXXX should simply giving 'text' as a target do it better?
	$(X2R) $D/f-$S.xml $D/$S-$V.txt
	/bin/cp $S-$V.txt $Sspec.txt
	/bin/cp $Sspec.txt $(WDIR)
	scp -p $Sspec.html $Sspec.txt \
		$(prod):/cdlib/apache/htdocs/services/uc3/$S/
	@echo "Copied $Sspec.{html,txt} -> inside/diglib/$S (staging)."
