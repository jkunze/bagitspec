default: html text

text:
	xml2rfc bagit.xml

html:
	xml2rfc --html bagit.xml

format:
	# We can't enable c14n because that triggers external DTD fetching and
	# libxml2 currently does not support HTTPS, which is a problem now that all
	# of the xml.resource.org URLs redirect:
	xmllint --format --output bagit.xml bagit.xml
