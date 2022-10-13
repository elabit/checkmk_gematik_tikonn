ARG VARIANT
# This Dockerfile is the basis for the VS Code devcontainer. It is based on the cmk-python3-dev image.
# NOTE: First build the "cmk-python3-dev" image(s) with .devcontainer/devcontainer_img_build.sh !

# Platform is important to also run this container on Apple M1, see https://stackoverflow.com/a/69798220
FROM --platform=linux/amd64 cmk-python3-dev:${VARIANT}

# In most cases, you won't need to add anything here so that the project specific images created 
# from this are all identical. 
# But for the case you need to install some special binaries etc. you can add them here.
# They will be available only in the project specific image then.

# The entrypoint creates the OMD site, executes post-start hook and halts before site start.
# Customization option 1) Add your own scripts to the post-create folder (1 layer result)
COPY docker-entrypoint.d /docker-entrypoint.d
RUN /docker-entrypoint.sh /bin/true

# Customization option 2) Install your own stuff here if you prefer single Docker layers
# Project dependencies can also be installed in postCreateCommend.sh (using the default Docker image)
# see Ref #6TEtDq
# ADD YOUR CUSTOMIZATION HERE
# ...

ENTRYPOINT ["/bin/bash"]