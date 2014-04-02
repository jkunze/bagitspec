default: html text

html:
	xml2rfc bagit.xml

text:
	xml2rfc --html bagit.xml
