#!/usr/bin/env Rscript --vanilla
library(ggplot2)

# Usage: Rscript --vanilla plot_event_file </path/to/event.tsv file>
# (Assumes that its being run at the top of the BIDS directory.)

file <- commandArgs(trailingOnly=TRUE)
print(file)

file.base <- basename(file)
file.base.noext <- gsub("(.tsv|.nii.gz)", "", file.base)

task <- gsub(".+_task-([^_]+)_.+$", "\\1", file.base.noext)

data <- read.delim(file, na.strings="n/a")

if (task == "arrows") {
  data$cue <- ifelse(data$trial_type == "Pic", "IAPS_Picture", as.character(data$cue_to_participant))
  p <- ggplot(data, aes(x=onset))
  p + geom_point(pch=22, size=3, aes(y=trial_type, fill=cue)) + 
    scale_y_discrete(limits=c("Instruction", "ITI", "Cue", "Pic", "Blank", "ConfirmRating", "Rest")) + 
    labs(title=file.base.noext)
} else if (task == "faces") {
  data$trial_type <- factor(data$trial_type, levels=c("ITI", "Blank", "angry", "happy", "neutral", "ConfirmRating", "Rest"))
  p <- ggplot(data, aes(x=onset))
  p + geom_point(pch=22, size=3, alpha=0.5, aes(y=trial_type, fill=event_type)) + labs(title=file.base.noext)
} else if (task == "hands") {
  data$trial_type <- factor(data$trial_type, levels=c("ITI", "Blank", "Pic2", "ConfirmRating", "Rest"))
  p <- ggplot(data, aes(x=onset))
  p + geom_point(pch=22, size=3, aes(y=trial_type, fill=event_type)) + 
    scale_y_discrete(limits=c("ITI", "Pic2", "Blank", "ConfirmRating", "Rest")) + 
    labs(title=file.base.noext)
} else if (task == "sleepiness") {
  data$trial_type <- factor(data$trial_type, levels=c("Fixation+", "Response"))
  p <- ggplot(data, aes(x=onset))
  p + geom_point(pch=22, size=3, aes(y=trial_type), fill='#999999') + 
    scale_y_discrete(limits=c("Fixation+", "Response")) + 
    labs(title=file.base.noext)
} else {
  #data$trial_type <- factor(data$trial_type, levels=c("ITI", "Blank", "Pic2", "ConfirmRating", "Rest"))
  p <- ggplot(hands, aes(x=onset))
  p + geom_point(pch=22, size=3, aes(y=trial_type, fill=event_type)) + labs(title=file.base.noext)
}

output_file <- sprintf('derivatives/event_plots/%s/%s.pdf', 
                      dirname(file), file.base.noext)

dir.create(dirname(output_file), recursive=TRUE, showWarnings=FALSE)
ggsave(filename=output_file, w=10, h=4, plot=last_plot())

