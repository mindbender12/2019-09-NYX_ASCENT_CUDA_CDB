# Description of the pipeline:

This is a demonstration of an end-to-end pipeline that performs GPU-enabled distributed environment in situ data analysis and visualization using the ECP ExaSky application Nyx. Using ECP ALPINE in situ infrastructure Ascent, the pipeline accesses the appropriate Nyx simulation data and performs data sub-sampling via ALPINE data-driven sampling algorithm. The adaptive spatial sampling algorithm prioritizes rare data values while selecting sample points. As a result, the important features in the data such as Halos in Nyx simulation are preserved. Finally, a cinema database is generated in situ using ALPINE Ascent containing data artifacts as renderings of the output sub-sampled data.

The output cinema database is further processed in a post-processing phase where the artifacts, i.e., the rendered images generated in situ are further analyzed via several cinema algorithms for identifying unique images and also estimating information entropy of the images. As a result, new cinema artifacts are created and are added to the existing cinema database. Finally, an automated cinema algorithm is used to generate browser-based viewers for viewing and analyzing such cinema databases interactively.

# Cloning this Git repository.

This repository makes use of git submodules. Clone with the recursive option, or be sure to `git submodule init; git submodule update` before running.

# How to run

First, be sure you agree with the default choices in `env.sh`. Use `popper run` from base directory this git repo to build and run the experiment.


# Dependencies

- Must run on Summit
- Bash
- Popper version v2.3.0+ [link](https://falsifiable.us)
