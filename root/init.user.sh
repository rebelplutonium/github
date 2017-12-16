#!/bin/sh

echo "${UPSTREAM_ID_RSA}" > /home/user/.ssh/upstream_id_rsa &&
    echo "${ORIGIN_ID_RSA}" > /home/user/.ssh/origin_id_rsa &&
    echo "${REPORT_ID_RSA}" > /home/user/.ssh/report_id_rsa &&
    ssh-keyscan -p ${HOST_PORT} "${HOST_NAME}" > /home/user/.ssh/known_hosts &&
    (cat > /home/user/.ssh/config <<EOF
Host upstream
HostName ${HOST_NAME}
Port ${HOST_PORT}
User git
IdentityFile ~/.ssh/upstream_id_rsa

Host origin
HostName ${HOST_NAME}
Port ${HOST_PORT}
User git
IdentityFile ~/.ssh/origin_id_rsa

Host report
HostName ${HOST_NAME}
Port ${HOST_PORT}
User git
IdentityFile ~/.ssh/report_id_rsa
EOF
    ) &&
    ln -sf /usr/local/bin/post-commit /opt/docker/workspace/.git/hooks/post-commit &&
    git -C /opt/docker/workspace config user.name "${USER_NAME}" &&
    git -C /opt/docker/workspace config user.email "${USER_EMAIL}" &&
    git -C /opt/docker/workspace remote add upstream upstream:${UPSTREAM_ORGANIZATION}/${UPSTREAM_REPOSITORY}.git &&
    git -C /opt/docker/workspace remote set-url --push upstream no_push &&
    git -C /opt/docker/workspace remote add origin origin:${ORIGIN_ORGANIZATION}/${ORIGIN_REPOSITORY}.git &&
    git -C /opt/docker/workspace remote add report report:${REPORT_ORGANIZATION}/${REPORT_REPOSITORY}.git &&
    (
        (
            git -C /opt/docker/workspace fetch upstream ${MASTER_BRANCH} &&
                git -C /opt/docker/workspace checkout upstream/${MASTER_BRANCH}
        ) ||
        (
            touch /opt/docker/workspace/README.md &&
                touch /opt/docker/workspace/.gitignore &&
                git -C /opt/docker/workspace add README.md .gitignore &&
                git -C /opt/docker/workspace checkout -b ${MASTER_BRANCH} &&
                mv /opt/docker/workspace/.git/hooks/post-commit /opt/docker/workspace/.git/hooks/post-commit.backup&&
                git -C /opt/docker/workspace commit -am "init" &&
                mv /opt/docker/workspace/.git/hooks/post-commit.backup /opt/docker/workspace/.git/post-commit &&
                git -C /opt/docker/workspace push report ${MASTER_BRANCH}
        )
    ) &&
    git -C /opt/docker/workspace checkout -b scratch/$(uuidgen) &&
    cat >> /home/user/.bashrc <<EOF
export MASTER_BRANCH=${MASTER_BRANCH}    
EOF

