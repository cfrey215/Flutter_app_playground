# Dockerfile

FROM ubuntu:20.04

RUN apt update && apt install -y sbcl

# create user
# RUN groupadd --gid $GID $USER \
#   && useradd -s /bin/bash --uid $UID --gid $GID -m $USER \
#   && echo $USER ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER \
#   && chmod 0440 /etc/sudoers.d/$USER

# USER $USER
# WORKDIR /home/$USER

# COPY entrypoint.sh /usr/local/bin/
# COPY --chown=$USER:$GID workspace workspace
ENV myDir="script"
RUN mkdir -p $myDir

# Copy the script to the container
COPY ./workspace/script/test.sh $myDir
RUN chmod +x $myDir/test.sh

# Set return environment variable
ENV RETURNED_VALUE="Test Run Id: 14sd45rsvb65ter4b6er75"

# Set the entrypoint to the script with CMD arguments
# ENTRYPOINT [ "/bin/bash", "-c", "exec ${myDir}/test.sh \"${@}\"", "--"]
# CMD ["hulk", "batman", "superman"]