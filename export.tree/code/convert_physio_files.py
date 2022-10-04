#!/usr/bin/env PYTHONPATH=/home1/03872/wtriplet/software/bioread/src python

### Note: script is written against commit c4cc10d from
###       git@github.com:njvack/bioread.git
### The current HEAD at the time of writing this script was
### dumping files with unequal lengths (despite sample rate
### being the same), and did not match up with the dumped .txt
### files that accompany some biopac files from the study

#import bioread # if using HEAD (different usage if so.)
from bioread.readers import AcqReader
import pandas
import sys, os
import json
import gzip

############################################################

class UsageError(Exception):
	def __init__ (self, value):
		self.value = value
	def __str__ (self):
		return repr(self.value)

############################################################

if len(sys.argv) != 2:
	print ("Usage: command biopac_file")
	raise UsageError("Usage: command: biopac_file")

biopac_file = sys.argv[1]

try:
	# if using master bioread
	#bioread_file = bioread.read_file(biopac_file)

	bioread_file = AcqReader.read_file(biopac_file)
	channels = bioread_file.channels

	channel_info = { "SamplingFrequency": channels[0].samples_per_second,
	                 "StartTime" : 0.00,
	                 "Note": "Neutral, Happy, Angry columns contain event onset reference signals.",
	                 "Columns": [] ,
	                 "Units" : [] }

	df = pandas.DataFrame([])

	for i, channel in enumerate(channels):
		unified_col_name = channel.name
		channel_id = "%s_%d" % (unified_col_name, i) 
		print("%d\t%s\t%s\t%d\t%s" % (i, channel.name, channel.units, channel.samples_per_second, channel_id))
		df[channel_id] = channel.data
		channel_info["Units"].append(channel.units)
		channel_info["Columns"].append(unified_col_name)

	csv_outfile = os.path.splitext(biopac_file)[0] + '.tsv.gz'
	json_outfile = os.path.splitext(biopac_file)[0] + '.json'

	with gzip.open(csv_outfile, 'w') as csvout:
		df.to_csv(csvout, sep="\t", na_rep="n/a", header=True, index=False)

	with open(json_outfile, 'w') as jsout:
		json.dump(channel_info, jsout, indent=4)

	os.chmod(json_outfile, 0o664)
	os.chmod(csv_outfile, 0o664)

	print ("Converted: %s to %s" % (biopac_file, csv_outfile))

	sys.exit(0)

except SystemExit:
 	pass

