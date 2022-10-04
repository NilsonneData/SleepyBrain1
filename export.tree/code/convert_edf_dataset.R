#library(ebm) # install_github("wtriplett/embla-r", ref="minor-fixes")
library(jsonlite)
library(edf)

#args <- commandArgs(trailingOnly=TRUE)
#ebm_dirs <- args[1:length(args)]

fp <- file('edf_files', 'r')
edf_files <- readLines(fp)
close(fp)

for (f in edf_files) {
  file.bits <- unlist(strsplit(basename(f), '_'))
  subj.info.from.file <- list(
    id <- file.bits[2],
    sess <- file.bits[3],
    date <- gsub(".edf", "", file.bits[4])
  )
  print(f)
  rec <- read.edf(f, read.annotations=FALSE)

  header.signal <- rec$header.signal
  properties <- rec$properties
  chan.names <- names(header.signal)
  print(chan.names)
  for (chan.name in chan.names) {
    
    hdr <- header.signal[[chan.name]]
    # not sure why these would every have different
    # lengths, but don't want to risk it.

    hdr$subject_id <- subj.info.from.file$id
    hdr$session_id <- subj.info.from.file$sess
    hdr$file_date_label <- subj.info.from.file$date
    
    # put in source folder / channels_converted / Fp_XXX_AA_DDDD_<channelname>.{json,tsv}
    outfile.base <- file.path(dirname(f), 
                              "channels_converted", 
                              sprintf("%s_%s", gsub(".edf", "", basename(f)), chan.name))

    dir.create(dirname(outfile.base), recursive=TRUE, mode="0777", showWarnings=FALSE)
    fp.json <- file(sprintf("%s.json", outfile.base), 'w')
    cat(toJSON(hdr, pretty=TRUE, auto_unbox=TRUE, digits=10), file=fp.json)
    close(fp.json)
    
    data <- rec$signal[[chan.name]]
    plot(data$t, data$data, type='l', main=chan.name)
    if (length(data$data) == 0) {
      warning(sprintf("Zero-length data vector for channel %s in file: %s", chan.name, f))
      next
    }
    
    data.tbl <- data.frame(time=data$t, signal=data$data)
    fp.tsv.gz <- gzfile(sprintf("%s.tsv.gz", outfile.base), compression=9)
    write.table(data.tbl, file=fp.tsv.gz, sep="\t", row.names=FALSE, col.names=FALSE, 
                quote=FALSE, na="n/a", fileEncoding='utf-8')
  }
  rm(rec)
}
