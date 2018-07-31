#!/bin/sh

echo "${UPSTREAM_ID_RSA}" > /home/user/.ssh/upstream_id_rsa &&
    echo "${ORIGIN_ID_RSA}" > /home/user/.ssh/origin_id_rsa &&
    echo "${REPORT_ID_RSA}" > /home/user/.ssh/report_id_rsa &&
    ssh-keyscan -p ${HOST_PORT} "${HOST_NAME}" > /home/user/.ssh/known_hosts &&
    (cat > /home/user/.ssh/config <<EOF
Host upstream
HostName ${UPSTREAM_HOST}
Port ${UPSTREAM_PORT}
User git
IdentityFile ~/.ssh/upstream_id_rsa

Host origin
HostName ${ORIGIN_HOST}
Port ${ORIGIN_PORT}
User git
IdentityFile ~/.ssh/origin_id_rsa

Host report
HostName ${REPORT_HOST}
Port ${REPORT_PORT}
User git
IdentityFile ~/.ssh/report_id_rsa
EOF
    ) &&
    ln -sf /usr/local/bin/post-commit ${CLOUD9_WORKSPACE}/.git/hooks/post-commit &&
    git -C ${CLOUD9_WORKSPACE} git init &&
    git -C ${CLOUD9_WORKSPACE} config user.name "${COMMITTER_NAME}" &&
    git -C ${CLOUD9_WORKSPACE} config user.email "${COMMITTER_EMAIL}" &&
    git -C ${CLOUD9_WORKSPACE} remote add upstream upstream:${UPSTREAM_ORGANIZATION}/${UPSTREAM_REPOSITORY}.git &&
    git -C ${CLOUD9_WORKSPACE} remote set-url --push upstream no_push &&
    git -C ${CLOUD9_WORKSPACE} remote add origin origin:${ORIGIN_ORGANIZATION}/${ORIGIN_REPOSITORY}.git &&
    git -C ${CLOUD9_WORKSPACE} remote add report report:${REPORT_ORGANIZATION}/${REPORT_REPOSITORY}.git &&
    git -C ${CLOUD9_WORKSPACE} fetch upstream ${MASTER_BRANCH} &&
    git -C ${CLOUD9_WORKSPACE} checkout -b issue-$(printf "%05d" ${ISSUE_NUMBER})-$(uuidgen) &&
    TEMP=$(mktemp -d) &&
    echo "${GPG_SECRET_KEY}" > ${TEMP}/gpg-secret-key &&
    gpg --batch --import ${TEMP}/gpg-secret-key &&
    echo "${GPG2_SECRET_KEY}" > ${TEMP}/gpg2-secret-key &&
    gpg2 --batch --import ${TEMP}/gpg2-secret-key &&
    echo "${GPG_OWNER_TRUST}" > ${TEMP}/gpg-owner-trust &&
    gpg --batch --import-ownertrust ${TEMP}/gpg-owner-trust &&
    echo "${GPG2_OWNER_TRUST}" > ${TEMP}/gpg2-owner-trust &&
    gpg2 --batch --import-ownertrust ${TEMP}/gpg2-owner-trust &&
    rm -rf ${TEMP} &&
    git -C ${CLOUD9_WORKSPACE} config --global user.signingkey ${GPG_KEY_ID} &&
    cat >> /home/user/.bashrc <<EOF
export MASTER_BRANCH=${MASTER_BRANCH}    
EOF
