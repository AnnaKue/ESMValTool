"""
# #############################################################################
# hyint.py
# Authors:       E. Arnone (ISAC-CNR, Italy)
#                J. von Hardenberg (ISAC-CNR, Italy)
# #############################################################################
# Description
# This script writes only references for the Hy-Int diagnostics
#
# ############################################################################
"""

from esmval_lib import ESMValProject

def main(project_info):

    # create instance of a wrapper that allows easy access to data
    E = ESMValProject(project_info)

    config_file = E.get_configfile()
    verbosity = E.get_verbosity()
    diag_script = E.get_diag_script_name()

    if "hyint" in config_file:
       diag_refs=["D_giorgi14jgr", "D_giorgi11jc"]
       diag_script="hyint.r"

    res = E.write_references(diag_script,                # diag script name
                             ["A_arno_en", "A_hard_jo"], # authors
                             [""],                       # contributors
                             diag_refs,           # diag_references
                             ["E_erainterim"],           # obs_references
                             ["P_c3s34a"],               # proj_references
                             project_info,
                             verbosity,
                             False)

    datakeys = E.get_currVars()
    models = get_climo_filenames(E, variable=datakeys[0])
    #models = []
    #for model in E.project_info['MODELS']:
    #    print model.split_entries()

    #print "DATAKEYS: ", datakeys[0]
    #models = E.get_clim_model_filenames(datakeys[0])
    #models = E.get_clim_model_filenames(variable=datakeys[0])

    # Get the model paths etc. including the obs file for winds
#    models = E.get_clim_model_filenames(ua_key)

    for model in models:
       print "MODEL -->", model
       E.add_to_filelist(model)


def get_climo_filenames(E, variable):

    import projects
    import os

    res = []

    for currDiag in E.project_info['DIAGNOSTICS']:
        variables = currDiag.get_variables()
        field_types = currDiag.get_field_types()
        mip = currDiag.get_var_attr_mip()
        exp = currDiag.get_var_attr_exp()
        for idx in range(len(variables)):
            for model in E.project_info['MODELS']:
                currProject = getattr(vars()['projects'],
                                      model.split_entries()[0])()
                fullpath = currProject.get_cf_fullpath(E.project_info,
                                                       model,
                                                       field_types[idx],
                                                       variables[idx],
                                                       mip[idx],
                                                       exp[idx])
                if variable == variables[idx] and os.path.isfile(fullpath):
                    res.append(fullpath)
    return res

