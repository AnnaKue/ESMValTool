# #############################################################################
# miles.R
# Authors:       P. Davini (ISAC-CNR, Italy) (author of MiLES)
#	         J. von Hardenberg (ISAC-CNR, Italy) (ESMValTool adaptation)
# #############################################################################
# Description
# MiLES is a tool for estimating properties of mid-latitude climate originally thought
# for EC-Earth output and then extended to any model data.
# It works on daily 500hPa geopotential height data and it produces climatological figures 
# for the chosen time period. Data are interpolated on a common 2.5x2.5 grid.  
# Model data are compared against ECMWF ERA-INTERIM reanalysis for a standard period (1989-2010).
# It supports analysis for the 4 standard seasons.#
# Required
#
# Optional 
#
# Caveats
#
# Modification history
#
# ############################################################################

source('diag_scripts/aux/miles/basis_functions.R')
source('diag_scripts/aux/miles/block_fast.R')
source('diag_scripts/aux/miles/block_figures.R')

source('interface_data/r.interface')
source('diag_scripts/lib/R/info_output.r')
source(diag_script_cfg)

## Do not print warnings
options(warn=-1)

var0 <- variables[1]
field_type0 <- field_types[1]

info_output(paste0("<<<<<<<< Entering ", diag_script), verbosity, 4)
info_output("+++++++++++++++++++++++++++++++++++++++++++++++++", verbosity, 1)
info_output(paste0("plot - ", diag_script, " (var: ", variables[1], ")"), verbosity, 1)
info_output("+++++++++++++++++++++++++++++++++++++++++++++++++", verbosity, 1)

library(tools)
#diag_base = file_path_sans_ext(diag_script)
diag_base = "MiLES"

## Create working dirs if they do not exist
work_dir=file.path(work_dir, diag_base)
plot_dir=file.path(plot_dir, diag_base)
zdir=paste0(work_dir,"/","Z500/")

dir.create(plot_dir, showWarnings = FALSE)
dir.create(work_dir, showWarnings = FALSE)
dir.create(climo_dir, showWarnings = FALSE)
dir.create(zdir, showWarnings = FALSE)

##
## Run it all
##

for (model_idx in c(1:(length(models_name)))) {
    exp <- models_name[model_idx]
    year1=models_start_year[model_idx]
    year2=models_end_year[model_idx]
    infile <- interface_get_fullpath(var0, field_type0, model_idx)

    system2('diag_scripts/aux/miles/z500_prepare.sh',c(exp,toString(year1),toString(year2), infile, zdir))
    for (seas in seasons) {
       miles.block.fast( year1=year1, year2=year2, exp=exp, season=seas,DATADIR=zdir,FILESDIR=work_dir)
    }
}

##
## Make the plots
##
#dataset_ref="ERAINTERIM"; year1_ref=1989; year2_ref=2010
#dataset_ref="EC-Earth"; year1_ref=2000; year2_ref=2001
ref_idx=length(models_name);
dataset_ref= models_name[ref_idx]
year1_ref=models_start_year[ref_idx]
year2_ref=models_end_year[ref_idx]

for (model_idx in c(1:(length(models_name)-1))) {
    exp <- models_name[model_idx]
    year1=models_start_year[model_idx]
    year2=models_end_year[model_idx]
    for (seas in seasons) {
       miles.block.figures( year1=year1, year2=year2, exp=exp, dataset_ref=dataset_ref, year1_ref=year1_ref, year2_ref=year2_ref, season=seas,FIGDIR=plot_dir,FILESDIR=work_dir,REFDIR=work_dir,CFGSCRIPT=diag_script_cfg)
    }
}
info_output(paste0(">>>>>>>> Leaving ", diag_script), verbosity, 4)
