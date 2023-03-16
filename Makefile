# This make file is used exclusively for converting the Markdown into Gemtext. This is really needed
# for anyone but me
all: gemtext images gallery index

index: gallery
	@echo "Adding navigation/index"
# generate index and add navigation links to the bottom of the posts
	@dotnet run --project ../ContentIndexer/ output/ "Warez"

gallery: gemtext
	@echo "Making Gallery"
	@grep -E -h '^!\[' Book/*.md > output/gallery.md
	@printf '# Image Gallery\n\n' > output/gallery.gmi
	@perl -npe 's/!\[(.+)?\]\(([^\)]+)\)/=> $$2 $$1/' output/gallery.md >> output/gallery.gmi
	@rm -f output/gallery.md

gemtext: images
	@echo "Converting to Gemtext"
# convert the footnotes
	@perl -i -n -p -e 's/^\[\^(\d+)\]\:\s/* $$1. /' output/*.md 
	
	@md2gemini --write --dir output/ --frontmatter --img-tag='' --links images-only output/*.md
	@rm output/*.md
# md2gemini annoyingly adds CRLF, regardless of platform
	@dos2unix -q output/*.gmi
	
images: output
	@echo "Optimizing images"
	@mogrify -strip -quality 80 -resize 1000x1000\> output/images/*

output: clean
	@echo "Creating 'output/'"
	@mkdir output
	@cp -R Book/* output/.

clean:
	@echo "Cleaning"
	@rm -rf output
