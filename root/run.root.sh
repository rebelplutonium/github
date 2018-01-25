#!/bin/sh

dnf update --assumeyes &&
    dnf install --assumeyes gnupg gnupg2 &&
    dnf clean all